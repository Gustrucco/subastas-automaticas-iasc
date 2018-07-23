defmodule Buyer do
	use GenServer

	def start_link({id, name, ip, interestedTags}) do
		IO.puts "Buyer #{id} - start_link"
		GenServer.start_link(__MODULE__,
			{id, name, ip, interestedTags},
			name: {:global, "buyer:#{ip}"})
	end

	# SERVER

	def init({id, name, ip, interestedTags}) do
		IO.puts "Buyer #{id} - init"
		:ets.insert(:buyers, { id, self(), :calendar.universal_time(), ip, name, interestedTags })
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
		IO.puts "New bid #{bid[:id]}"
		run_if_is_interesting(buyer,bid,
			fn -> 
				#ACÁ SE LE PEGARÍA A UN AGENTE EXTERNO
				#HTTPoison.post "http://#{buyer[:id]}/newbid",
				#Jason.encode(buyer),
				#[{"Content-Type", "application/json"}],
				#[]
			end
		)
		{:noreply, buyer}
	end

	def handle_cast({:notify_new_price, bid}, buyer) do
		IO.puts "New offer in bid #{bid[:id]}"
		run_if_is_interesting(buyer,bid,
			fn -> 
				#ACÁ SE LE PEGARÍA A UN AGENTE EXTERNO
				#HTTPoison.post "http://#{buyer[:id]}/newpriceforbid",
				#Jason.encode(buyer),
				#[{"Content-Type", "application/json"}],
				#[]
			end
		)
		{:noreply, buyer}
	end

	def handle_cast({:notify_cancelation, bid}, buyer) do
		IO.puts "Bid #{bid[:id]} canceled"
		run_if_is_interesting(buyer,bid,
			fn -> 
				#ACÁ SE LE PEGARÍA A UN AGENTE EXTERNO
				#HTTPoison.post "http://#{buyer[:id]}/bidcancelation",
				#Jason.encode(buyer),
				#[{"Content-Type", "application/json"}],
				#[]
			end
		)
		{:noreply, buyer}
	end

	def handle_cast({:notify_ending, bid}, buyer) do
		IO.puts "Bid #{bid[:id]} finished"
		run_if_is_interesting(buyer,bid,
			fn -> 
				#ACÁ SE LE PEGARÍA A UN AGENTE EXTERNO
				#HTTPoison.post "http://#{buyer[:id]}/bidending",
				#Jason.encode(buyer),
				#[{"Content-Type", "application/json"}],
				#[]
			end
		)
		{:noreply, buyer}
	end
end