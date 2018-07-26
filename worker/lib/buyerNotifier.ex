defmodule BuyerNotifier do
	use GenServer

	def start_link(_arg) do
		GenServer.start_link(__MODULE__, [], name: __MODULE__)
	end

	# SERVER

	def init() do
		{:ok, []}
	end

	def getBuyers do
		List.flatten(:ets.match(:buyers, { :"_", :"$1", :"_", :"_", :"_", :"_"}))
	end

	def handle_cast({:notify_new_bid, bid}, state) do
		Enum.each(BuyerNotifier.getBuyers(), fn buyer -> GenServer.cast(buyer,{:notify_new_bid, bid}) end)
		{:noreply, state}
	end

	def handle_cast({:notify_new_price, bid}, state) do
		Enum.each(BuyerNotifier.getBuyers(), fn buyer -> GenServer.cast(buyer,{:notify_new_price, bid}) end)
		{:noreply, state}
	end

	def handle_cast({:notify_cancelation, bid}, state) do
		Enum.each(BuyerNotifier.getBuyers(), fn buyer -> GenServer.cast(buyer,{:notify_cancelation, bid}) end)
		{:noreply, state}
	end

	def handle_cast({:notify_ending, bid}, state) do
		Enum.each(BuyerNotifier.getBuyers(), fn buyer -> GenServer.cast(buyer,{:notify_ending, bid}) end)
		{:noreply, state}
	end
end