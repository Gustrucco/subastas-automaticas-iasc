#Dinamico
defmodule Bid.Supervisor do
	use DynamicSupervisor

	def start_link(_arg) do
    IO.puts "********* START_LINK Bid.Supervisor *********"
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    IO.puts "********* INIT Bid.Supervisor *********"
    DynamicSupervisor.init(strategy: :one_for_one)
  end

	def add_bid(id, defaultPrice, duration, tags, item) do
    IO.puts "********* start_child Bid.Supervisor *********"

    spec = Bid.child_spec({id, defaultPrice, duration, tags, item})
    transientSpec = Map.put(spec, :restart, :transient)
    DynamicSupervisor.start_child(__MODULE__, transientSpec)
  end
  
end
