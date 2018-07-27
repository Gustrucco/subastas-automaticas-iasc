defmodule Buyer do
	use GenServer

	def start_link({id, name, ip, interestedTags}) do
		IO.puts "Buyer #{id} - start_link"
		GenServer.start_link(__MODULE__,
			{id, name, ip, interestedTags},
			name: {:global, "buyer:#{id}"})
	end

	# SERVER

	def init({id, name, ip, interestedTags}) do
		IO.puts "Buyer #{id} - init"
		:ets.insert(:buyers, { id, self(), :calendar.universal_time(),name, ip, interestedTags })
		{:ok, %{:id => id, :name => name, :ip => ip ,:interestedTags => interestedTags }}
	end
	
	def interested_bid? buyer, bid do
		Enum.any?(buyer[:interestedTags],fn interestedTag -> Enum.member?(bid[:tags], interestedTag) end)
	end
	
	def run_if_is_interesting buyer, bid, function do
		if interested_bid?(buyer, bid) do
			function.()
		end
	end
	
	def handle_cast({:notify_new_bid, bid}, buyer) do
		run_if_is_interesting(buyer,bid,
			fn -> 
				IO.puts "New bid #{bid[:id]}"
				HTTPoison.post "http://#{buyer[:id]}/newbid",
				Jason.encode(bid),
				[{"Content-Type", "application/json"}]
			end
		)
		{:noreply, buyer}
	end

	def handle_cast({:notify_new_price, bid}, buyer) do
		run_if_is_interesting(buyer,bid,
			fn -> 
				IO.puts "New offer in bid #{bid[:id]}"
				HTTPoison.post "http://#{buyer[:id]}/newpriceforbid",
				Jason.encode(bid),
				[{"Content-Type", "application/json"}]
			end
		)
		{:noreply, buyer}
	end

	def handle_cast({:notify_cancelation, bid}, buyer) do
		run_if_is_interesting(buyer,bid,
			fn -> 
				IO.puts "Bid #{bid[:id]} canceled"
				HTTPoison.post "http://#{buyer[:id]}/bidcancelation",
				Jason.encode(bid),
				[{"Content-Type", "application/json"}]
			end
		)
		{:noreply, buyer}
	end

	def handle_cast({:notify_ending, bid}, buyer) do
		run_if_is_interesting(buyer,bid,
			fn -> 
				IO.puts "Bid #{bid[:id]} finished"
				HTTPoison.post "http://#{buyer[:id]}/bidending",
				Jason.encode(bid),
				[{"Content-Type", "application/json"}]
			end
		)
		{:noreply, buyer}
	end

	def handle_call({:ping},_from, buyer) do
		{:reply,:pong, buyer}
	end
end