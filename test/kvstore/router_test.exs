defmodule KVStore.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias KVStore.Router

  @opts Router.init([])

  test "returns welcome" do
    conn =
      conn(:get, "/", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "returns 1created" do
    :dets.open_file(:storg, [type: :set])

    attr = ["-X", "POST", "-d", "key=1&value=test&ttl=300", "127.0.0.1:8080/create"]
    assert {"Created", 0} == System.cmd("curl", attr)
  end

  test "returns 2read" do
    :timer.sleep(1500)

    attr = ["-X", "POST", "-d", "key=1", "127.0.0.1:8080/read"]

    assert {"test", 0} == System.cmd("curl", attr)
  end

  test "returns 3update" do
    :timer.sleep(500)

    attr1 = ["-X", "POST", "-d", "key=1&value=test1&ttl=99", "127.0.0.1:8080/update"]
    attr2 = ["-X", "POST", "-d", "key=1", "127.0.0.1:8080/read"]

    r1 = System.cmd("curl", attr1)
    r2 = System.cmd("curl", attr2)

    assert {"Updated", 0} == r1
    assert {"test1", 0} == r2
  end

  test "returns 4delete" do
    :timer.sleep(1500)

    attr = ["-X", "POST", "-d", "key=test1", "127.0.0.1:8080/delete"]
    :ok = :dets.delete(:storg, 1)
    
    assert {"Deleted", 0} == System.cmd("curl", attr)
  end

  test "returns 404" do
    conn =
      conn(:get, "/missing", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
