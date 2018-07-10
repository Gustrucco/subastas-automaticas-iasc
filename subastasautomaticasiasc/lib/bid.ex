defmodule Bid do
	use GenServer

	def start_link do
		GenServer.start_link(__MODULE__, [])
	end

	# SERVER

	def init(%{:tags => tags , :defaultPrice => defaultPrice , :duration => duration, :item => item, :buyerNotifier => buyerNotifier }) do
		timer = Process.send_after(self(), :end_bid, duration)
		#Si el init se ejecuta con el actor ya creado, notificar de la nueva subasta
		#Si no ver donde hacer esa logica
		{:ok, %{:tags => tags,
		 :defaultPrice => defaultPrice,
		 :duration => duration,
		 :item => item,
		 :buyerNotifier => buyerNotifier,
		 :actualPrice => defaultPrice,
		 :actualWinner => ""
		 }}
	end

	def handle_cast({:end_bid}, bid) do
		GenServer.cast(bid[:buyerNotifier],{:notify_ending,bid})
		{:noreply, bid}
	end

	def handle_cast({:new_offer, price}, bid) do
		GenServer.cast(bid[:buyerNotifier],{:notify_new_price,bid})
		{:noreply, Map.put(bid,:actualPrice,price)}
	end

	def handle_cast({:cancel}, bid) do
		GenServer.cast(bid[:buyerNotifier],{:notify_cancelation,bid})
		Process.exit(self(), :shutdown)
		{:noreply, bid}
	end
end