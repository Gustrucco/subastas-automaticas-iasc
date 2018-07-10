#Dinamico
defmodule Buyer.Supervisor do
  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(implicit_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
     	extra_arguments: [implicit_arg]
    )
  end

	def start_child() do
    # This will start child by calling Worker.start_link(implicit_arg, foo, bar, baz)
	 # https://github.com/elixir-lang/elixir/issues/7369
	spec = Supervisor.Spec.worker(Buyer, [])
	DynamicSupervisor.start_child(__MODULE__, spec)
  end

end