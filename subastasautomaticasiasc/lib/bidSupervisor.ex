#Dinamico
defmodule Bid.Supervisor do
	use DynamicSupervisor

	def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

	def add_bid(tags, defaultPrice, duration, item, buyerNotifier) do
    	# This will start child by calling Worker.start_link(arg)
      # https://github.com/elixir-lang/elixir/issues/7369
      IO.puts "********* start_child Buyer.Supervisor *********"
    	
      spec = Bid.child_spec({tags, defaultPrice, duration, item, buyerNotifier})
      DynamicSupervisor.start_child(__MODULE__, spec)
  end
  
end