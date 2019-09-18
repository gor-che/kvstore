defmodule KVStore.Storage do

  def create conn do
    %{"key" => key, "value" => value, "ttl" => ttl1} = conn.params
    ttl2 = String.to_integer(ttl1)
    expiration = :os.system_time(:seconds) + ttl2
    :dets.insert(:storg, {key, value, expiration})
    :ok
  end

  def read conn do
    %{"key" => key} = conn.params
    r = :dets.lookup(:storg, key)
    check_freshness(r)
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
