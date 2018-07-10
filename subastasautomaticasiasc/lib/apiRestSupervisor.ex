#Estatico
#defmodule ApiRest.Supervisor do
#  use Supervisor

#	def start_link do
#		Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
#	end

#	def init(:ok) do
#		children = [
#			Supervisor.child_spec({MyAPP.API, []}, id: MyAPP.API)
#		]
#		Supervisor.init(children, strategy: :one_for_one)
#	end

#end