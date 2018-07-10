defmodule BuyerNotifier do
	use GenServer

	def start_link do
		GenServer.start_link(__MODULE__, [])
	end

	def add_buyer(pid, buyer) do
		GenServer.cast(pid, {:add_buyer, buyer})
	end

	def get_buyers(pid) do
		GenServer.call(pid, :get_buyers)
	end

	# SERVER

	def init(buyers) do
		{:ok, buyers}
	end

	def handle_cast({:add_buyer, new_buyer}, buyers) do
		{:noreply, [new_buyer | buyers]}
	end

	def handle_call(:get_buyers, _from, buyers) do
		{:reply, buyers, buyers}
	end
end