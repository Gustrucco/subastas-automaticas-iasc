defmodule Bid do
	use GenServer

	def start_link({tags, defaultPrice, duration, item, buyerNotifier}) do
		IO.puts "Bid - start_link"
		GenServer.start_link(__MODULE__,
			{tags, defaultPrice, duration, item, buyerNotifier},
			name: {:global, "bid:#{item}"})
	end

	# SERVER

	def init({defaultPrice, duration, tags, item, buyerNotifier}) do
		IO.puts "Bid - init"
		Process.send_after(self(), :end_bid, duration)
		bidId = System.system_time()
		IO.puts bidId
		:ets.insert(:bids, { bidId, tags, defaultPrice, duration, item, buyerNotifier, defaultPrice, "", :calendar.universal_time()})
		{:ok, %{ :id => bidId,
		 :tags => tags,
		 :defaultPrice => defaultPrice,
		 :duration => duration,
		 :item => item,
		 :buyerNotifier => buyerNotifier,
		 :actualPrice => defaultPrice,
		 :actualWinner => ""
		 }}
	end

	def bid_for_buyer(bid) do
		%{:tags => bid[:tags],
		 :price =>bid[:actualPrice],
		 :item => bid[:item],
		 :bidPid => :erlang.pid_to_list(self())}
	end
	
	def handle_info(:end_bid, bid) do
		GenServer.cast(bid[:buyerNotifier],{:notify_ending,bid})
		:ets.delete(:bids, bid[:id])
		Process.exit(self(), :shutdown)
		{:noreply, bid}
	end

	def handle_cast({:new_offer, price, winner}, bid) do
		newBid = Map.put(bid, :actualPrice, price)
		newBid = Map.put(bid, :actualWinner, winner)
		:ets.insert(:bids, { bid[:id], bid[:tags], bid[:defaultPrice], bid[:duration], bid[:item], bid[:buyerNotifier], bid[:price], winner, :calendar.universal_time()})
		GenServer.cast(bid[:buyerNotifier],{:notify_new_price,Bid.bid_for_buyer(newBid)})
		{:noreply, newBid}
	end

	def handle_cast({:cancel}, bid) do
		GenServer.cast(bid[:buyerNotifier],{:notify_cancelation,Bid.bid_for_buyer(bid)})
		:ets.delete(:bids, bid[:id])
		Process.exit(self(), :shutdown)
		{:noreply, bid}
	end
end