defmodule KVStore do
  use Application
  require Logger

  def start(_type, _args) do
    :dets.open_file(:storg, [type: :set])
    
    port = Application.get_env(:dbase, :cowboy_port, 8080)

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, KVStore.Router, [], port: port)
    ]

    Logger.info("Started application")

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
