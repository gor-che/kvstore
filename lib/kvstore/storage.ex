defmodule KVStore.Storage do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :fresh_data, 5000)
    {:ok, state}
  end

  def handle_info(:fresh_data, state) do
    time_now = :os.system_time(:seconds)
     ## fun = :ets.fun2ms(fn {key, _value, ttl} when ttl < time_now -> key end)
    fun = [{{:"$1", :"$2", :"$3"}, [{:<, :"$3", {:const, time_now}}], [:"$1"]}]
    keys = :dets.select(:storg, fun)
    for key <- keys do
      :dets.delete(:storg, key)
      IO.inspect key
      IO.puts "already old and deleted\n"
    end
    Process.send_after(self(), :fresh_data, 5000)
    {:noreply, state}
  end

  def create conn do
    %{"key" => key, "value" => value, "ttl" => ttl1} = conn.params
    ttl2 = String.to_integer(ttl1)
    expiration = :os.system_time(:seconds) + ttl2
    :dets.insert(:storg, {key, value, expiration})
    :ok
  end

  def read conn do
    %{"key" => key} = conn.params
    :dets.lookup(:storg, key)
  end

  def update conn do
    %{"key" => key, "value" => value} = conn.params
    r = :dets.lookup(:storg, key)
    case :dets.lookup(:storg, key) do
      [{key, _val, ttl}] -> :dets.insert(:storg, {key, value, ttl})
      _ -> :false
    end
  end

  def delete conn do
    %{"key" => key} = conn.params
    :dets.delete(:storg, key)
  end

  defp check_freshness([{key, result, expiration}]) do 
    cond do 
      expiration > :os.system_time(:seconds) -> result  
      :else -> 
        :dets.delete(:storg, key)
        :empty 
    end  
  end 
  defp check_freshness(_any)do
    :empty
  end
end
