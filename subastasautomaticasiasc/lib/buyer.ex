defmodule Buyer do
	use GenServer

	def start_link do
		GenServer.start_link(__MODULE__, [])
	end

	# SERVER

	def init(%{:name => name , :ip => ip , :interestedTags => interestedTags }) do
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