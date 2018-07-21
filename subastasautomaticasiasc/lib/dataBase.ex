defmodule DataBase do
use GenServer

  def start_link(_) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    GenServer.call(pid, :create_tables)
    {:ok, pid}
  end

  def handle_call(:create_tables, _from, _) do
    :ets.new(:buyers, [:set, :public, :named_table])
	:ets.new(:bids, [:set, :public, :named_table])
  end
end

#:ets.lookup(:buyers, ip)

#:ets.lookup(:bids, id)
