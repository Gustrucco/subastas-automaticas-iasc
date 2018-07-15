defmodule Bid do
	use GenServer

	def start_link({tags, defaultPrice, duration, item, buyerNotifier}) do
	IO.puts "Bid - start_link"
		GenServer.start_link(__MODULE__,
			{tags, defaultPrice, duration, item, buyerNotifier},
			name: {:global, "bid:#{item}"})
	end

	# SERVER

	def init({tags, defaultPrice, duration, item, buyerNotifier}) do
		IO.puts "Bid - init"
		timer = Process.send_after(self(), :end_bid, duration)
		{:ok, %{:tags => tags,
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
		Process.exit(self(), :shutdown)
		{:noreply, bid}
	end

	def handle_cast({:new_offer, price}, bid) do
		newBid = Map.put(bid,:actualPrice,price)
		GenServer.cast(bid[:buyerNotifier],{:notify_new_price,Bid.bid_for_buyer(newBid)})
		{:noreply, newBid}
	end

	def handle_cast({:cancel}, bid) do
		GenServer.cast(bid[:buyerNotifier],{:notify_cancelation,Bid.bid_for_buyer(bid)})
		Process.exit(self(), :shutdown)
		{:noreply, bid}
	end
end