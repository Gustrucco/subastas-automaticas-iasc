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

	def notify_new_bid(pid, bid) do
		GenServer.cast(pid, {:notify_new_bid, bid})
	end

	def notify_new_price(pid, bid) do
		GenServer.cast(pid, {:notify_new_price, bid})
	end

	def notify_cancelation(pid, bid) do
		GenServer.cast(pid, {:notify_cancelation, bid})
	end

	# SERVER

	def init() do
		{:ok, []}
	end

	def handle_cast({:add_buyer, new_buyer}, buyers) do
		{:noreply, [new_buyer | buyers]}
	end

	def handle_cast({:notify_new_bid, bid}, buyers) do
		Enum.each(buyers, fn buyer -> GenServer.cast(buyer,{:notify_new_bid, bid}) end)
		{:noreply, buyers}
	end

	def handle_cast({:notify_new_price, bid}, buyers) do
		Enum.each(buyers, fn buyer -> GenServer.cast(buyer,{:notify_new_price, bid}) end)
		{:noreply, buyers}
	end

	def handle_cast({:notify_cancelation, bid}, buyers) do
		Enum.each(buyers, fn buyer -> GenServer.cast(buyer,{:notify_cancelation, bid}) end)
		{:noreply, buyers}
	end

	def handle_cast({:notify_ending, bid}, buyers) do
		Enum.each(buyers, fn buyer -> GenServer.cast(buyer,{:notify_ending, bid}) end)
		{:noreply, buyers}
	end

	def handle_call(:get_buyers, _from, buyers) do
		{:reply, buyers, buyers}
	end
end