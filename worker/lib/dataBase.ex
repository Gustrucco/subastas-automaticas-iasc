defmodule DataBase do
	use GenServer

	def start_link(_) do
		GenServer.start_link(__MODULE__, [])
	end

	def init() do
      	IO.puts "** Creating databases **"
		:ets.new(:buyers, [:set, :public, :named_table])
		:ets.new(:bids, [:set, :public, :named_table])
	end
end

#:ets.lookup(:buyers, ip)

#:ets.lookup(:bids, id)
