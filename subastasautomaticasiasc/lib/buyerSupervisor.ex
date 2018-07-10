#Dinamico
defmodule Buyer.Supervisor do
  use DynamicSupervisor

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  #ARG: %{:name => name , :ip => ip , :interestedTags => interestedTags}
	def start_child(arg) do
    # This will start child by calling Worker.start_link(arg)
    # https://github.com/elixir-lang/elixir/issues/7369

    spec = Buyer.child_spec(arg)
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

end