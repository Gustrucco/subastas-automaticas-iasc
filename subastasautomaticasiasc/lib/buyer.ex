defmodule Buyer do
	use GenServer

	def start_link({name, ip, interestedTags}) do
		IO.puts "Buyer - start_link"
		GenServer.start_link(__MODULE__,
			{name, ip, interestedTags},
			name: {:global, "buyer:#{ip}"})
	end

	# SERVER

	def init({name, ip, interestedTags}) do
		IO.puts "Buyer - init"
		{:ok, %{:name => name , :ip => ip ,:interestedTags => interestedTags }}
	end
	
	def interested_bid? buyer, bid do
		Enum.any?(buyer[:interestedTags],fn interestedTag -> Enum.any?(bid[:tags],fn tag -> tag == interestedTag end) end)
	end
	
	def run_if_is_interesting buyer, bid, function do
		if interested_bid?(buyer, bid) do
			function.()
		end
	end
	
	def handle_cast({:notify_new_bid, bid}, buyer) do
		run_if_is_interesting(buyer,bid,
			fn -> 
				HTTPoison.post "http://#{buyer[:ip]}/newBid",
				Jason.encode(buyer),
				[{"Content-Type", "application/json"}],
				[]
			end
		)
		{:noreply, buyer}
	end

	def handle_cast({:notify_new_price, bid}, buyer) do
		run_if_is_interesting(buyer,bid,
			fn -> 
				HTTPoison.post "http://#{buyer[:ip]}/newPriceForBid",
				Jason.encode(buyer),
				[{"Content-Type", "application/json"}],
				[]
			end
		)
		{:noreply, buyer}
	end

	def handle_cast({:notify_cancelation, bid}, buyer) do
		run_if_is_interesting(buyer,bid,
			fn -> 
				HTTPoison.post "http://#{buyer[:ip]}/bidCancelation",
				Jason.encode(buyer),
				[{"Content-Type", "application/json"}],
				[]
			end
		)
		{:noreply, buyer}
	end

	def handle_cast({:notify_ending, bid}, buyer) do
		run_if_is_interesting(buyer,bid,
			fn -> 
				HTTPoison.post "http://#{buyer[:ip]}/bidEnding",
				Jason.encode(buyer),
				[{"Content-Type", "application/json"}],
				[]
			end
		)
		{:noreply, buyer}
	end
end