defmodule Bid do
	use GenServer

	def start_link({id, defaultPrice, duration, tags, item}) do
		IO.puts "Bid #{id} - start_link"
		GenServer.start_link(__MODULE__,
			{id, defaultPrice, duration, tags, item},
			name: {:global, "bid:#{id}"})
	end

	# SERVER

	def init({id, defaultPrice, duration, tags, item}) do
		IO.puts "Bid #{id} - init"
		Process.send_after(self(), :end_bid, duration * 1000)
		:ets.insert(:bids, { id, self(), :calendar.universal_time(), defaultPrice, duration, tags, item, defaultPrice, 0, false})

		WorkerUtils.to_all_notifier(fn(notifier) -> 
			GenServer.cast(notifier,{:notify_new_bid, %{ :id => id, :tags => tags, :price => defaultPrice, :item => item }})
		end)
		
		{:ok, %{ :id => id,
		 :tags => tags,
		 :defaultPrice => defaultPrice,
		 :duration => duration,
		 :item => item,
		 :actualPrice => defaultPrice,
		 :actualWinner => 0
		}}
	end

	def bid_for_buyer(bid) do
		%{ :id => bid[:id],
		 :tags => bid[:tags],
		 :price =>bid[:actualPrice],
		 :item => bid[:item]}
	end
	
	def handle_info(:end_bid, bid) do
		IO.puts "Bid #{bid[:id]} ended"
		
		:ets.insert(:bids, { bid[:id], self(), :calendar.universal_time(), bid[:defaultPrice], bid[:duration], bid[:tags], bid[:item], bid[:actualPrice], bid[:actualWinner], true})

		WorkerUtils.to_all_notifier( fn (notifier) -> 
			GenServer.cast(notifier, {:notify_ending, bid})
		end)

		Process.exit(self(), :shutdown)
		{:noreply, bid}
	end

	def handle_cast({:new_offer, price, winner}, bid) do
		newBid = Map.put(bid, :actualPrice, price)
		newBid = Map.put(newBid, :actualWinner, winner)

		:ets.insert(:bids, { bid[:id], self(), :calendar.universal_time(), bid[:defaultPrice], bid[:duration], bid[:tags], bid[:item], price, winner, false})
		
		WorkerUtils.to_all_notifier( fn (notifier) -> 
			GenServer.cast(notifier, {:notify_new_price,Bid.bid_for_buyer(newBid)})
		end)
		{:noreply, newBid}
	end

	def handle_cast(:cancel, bid) do
		IO.puts "Bid #{bid[:id]} canceled"

		:ets.insert(:bids, { bid[:id], self(), :calendar.universal_time(), bid[:defaultPrice], bid[:duration], bid[:tags], bid[:item], bid[:actualPrice], bid[:actualWinner], true})
		
		WorkerUtils.to_all_notifier( fn (notifier) -> 
			GenServer.cast(notifier,{:notify_cancelation,Bid.bid_for_buyer(bid)})
		end)
		
		Process.exit(self(), :shutdown)
		{:noreply, bid}
	end

	def handle_call({:ping},_from, bid) do
		{:reply,:pong, bid}
	end

end