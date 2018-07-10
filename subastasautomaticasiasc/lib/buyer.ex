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

	def handle_cast({:notify_new_bid, bid}, buyer) do
		#si esta interesado ofertar
		{:noreply, buyer}
	end

	def handle_cast({:notify_new_price, bid}, buyer) do
		#si esta interesado y no es el que va ganando ofertar
		{:noreply, buyer}
	end

	def handle_cast({:notify_cancelation, bid}, buyer) do
		#bien gracias
		{:noreply, buyer}
	end

	def handle_cast({:notify_ending, bid}, buyer) do
		#bien gracias
		{:noreply, buyer}
	end

	def handle_cast({:offer_accepted, bid}, buyer) do
		#bien gracias
		{:noreply, buyer}
	end

end