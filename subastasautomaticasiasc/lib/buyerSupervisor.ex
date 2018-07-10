#Dinamico
defmodule Buyer.Supervisor do
  use DynamicSupervisor

  def start_link(_arg) do
    IO.puts "********* START_LINK Buyer.Supervisor *********"
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    IO.puts "********* INIT Buyer.Supervisor *********"
    DynamicSupervisor.init(strategy: :one_for_one)
  end

	def add_buyer(name, ip, tags) do
    IO.puts "********* start_child Buyer.Supervisor *********"

    spec = Buyer.child_spec({name, ip, tags})
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

end