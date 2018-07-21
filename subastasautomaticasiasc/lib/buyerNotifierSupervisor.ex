defmodule BuyerNotifier.Supervisor do
  use Supervisor

	def start_link(_arg) do
		Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
	end

	def init(:ok) do
		children = [
			Supervisor.child_spec({BuyerNotifier, []}, id: BuyerNotifier)
		]
		Supervisor.init(children, strategy: :one_for_one)
	end

end