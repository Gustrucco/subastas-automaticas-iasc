defmodule Bid do
	use GenServer

	def start_link({defaultPrice, duration, tags, item}) do
		IO.puts "Bid - start_link"
		id = System.system_time()
		GenServer.start_link(__MODULE__,
			{id, defaultPrice, duration, tags, item},
			name: {:global, "bid:#{id}"})
	end

	# SERVER

	def init({id, defaultPrice, duration, tags, item}) do
		IO.puts "Bid - init"
		Process.send_after(self(), :end_bid, duration)
		IO.puts id
		:ets.insert(:bids, { id, defaultPrice, tags,duration, item, defaultPrice, "", :calendar.universal_time()})
		{:ok, %{ :id => id,
		 :tags => tags,
		 :defaultPrice => defaultPrice,
		 :duration => duration,
		 :item => item,
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
		#buscar buyerNotifier
		GenServer.cast(bid[:buyerNotifier],{:notify_ending,bid})
		:ets.delete(:bids, bid[:id])
		Process.exit(self(), :shutdown)
		{:noreply, bid}
	end

	def handle_cast({:new_offer, price, winner}, bid) do
		newBid = Map.put(bid, :actualPrice, price)
		newBid = Map.put(bid, :actualWinner, winner)
		:ets.insert(:bids, { bid[:id], bid[:tags], bid[:defaultPrice], bid[:duration], bid[:item], bid[:price], winner, :calendar.universal_time()})
		#buscar buyerNotifier
		GenServer.cast(bid[:buyerNotifier],{:notify_new_price,Bid.bid_for_buyer(newBid)})
		{:noreply, newBid}
	end

	def handle_cast({:cancel}, bid) do
		#buscar buyerNotifier
		GenServer.cast(bid[:buyerNotifier],{:notify_cancelation,Bid.bid_for_buyer(bid)})
		:ets.delete(:bids, bid[:id])
		Process.exit(self(), :shutdown)
		{:noreply, bid}
	end
end