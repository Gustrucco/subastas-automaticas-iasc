defmodule LoadBalancer do
	use GenServer

	def start_link(_arg) do
		GenServer.start_link(__MODULE__, %{nodes: []}, name: __MODULE__)
	end

	
	# SERVER

  def init(args) do
    Process.send(self(), :check_nodes,[])
  
		{:ok, args}
  end
  
  def worker_nodes do
    Enum.filter(Node.list,
    fn(node)-> Regex.match?(~r/worker/,Atom.to_string(node))end)
  end

  def node_to_node_token(node) do
    nodeName = List.first(String.split(Atom.to_string(node),"@"))
    splittedNodeName = String.split(nodeName,"-")
    nodeId = Enum.at(splittedNodeName,1)
    nodeNum = Enum.at(splittedNodeName,2)
    %{
      :node => node,
      :id => nodeId,
      :num => nodeNum
    }
  end
  
  def handle_info(:check_nodes, loadBalancer) do
    IO.puts("chequeando nodos")
    #agarro todos los nodes workers vivos y los hasheo
    workerNodes = Enum.map(WorkerUtils.worker_nodes(),fn(node) -> 
      WorkerUtils.node_to_node_token(node)
    end)
    
    #agarro todos los workers hasheados y los agrupo. Ejemplo de nodo  {node => :"worker-A-1@192.2.0", :id => "A", :num => 1}
    groupedWorkerNodes = Enum.group_by(workerNodes,fn(wkNode) ->
     wkNode[:id]
    end)

    #por cada grupo agarro
    Enum.each(Map.to_list(groupedWorkerNodes),fn ({k,value}) -> 
      firstReplica = List.first(Enum.sort_by(value,fn(node) -> node[:num] end)) #agarro la primera instancia de ese worker (que deberia ser la activa)
      node = firstReplica[:node]
      
      buyerAlive = true
      if(:rpc.call(node,:ets,:first,[:buyers]) != :"$end_of_table") do
        id = :rpc.call(node,:ets,:first,[:buyers])
        aBuyer =  Enum.at(Tuple.to_list(List.first(:rpc.call(node,:ets,:lookup,[:buyers,id]))),1)  
        buyerAlive = :rpc.call(node, Pid, :your_pid?, [aBuyer])
      end
      bidAlive = true
      if(:rpc.call(node,:ets,:first,[:bids]) != :"$end_of_table") do
        id = :rpc.call(node,:ets,:first,[:bids])
        aBid =  Enum.at(Tuple.to_list(List.first(:rpc.call(node,:ets,:lookup,[:bids,id]))),1)
        bidAlive = :rpc.call(node, Pid, :your_pid?, [aBid])
      end
      
      if(!bidAlive || !buyerAlive) do #Si alguno no esta vivo implicaria que el nodo se cayo
      IO.puts("reviviendo en #{Atom.to_string(node)}")
    
        deadBids = List.flatten(:rpc.call(node,:ets,:match,[:bids,:"$1"]))
        deadBuyers = List.flatten(:rpc.call(node,:ets,:match,[:buyers,:"$1"]))

        Enum.each(deadBuyers,fn(deadBuyer) ->  
           :rpc.call(node,Buyer.Supervisor,:add_buyer,[elem(deadBuyer,0),elem(deadBuyer,3),elem(deadBuyer,4),elem(deadBuyer,5)])
        end)
    
        Enum.each(Enum.filter(deadBids,fn(bid) -> !elem(bid,8) end ),fn(deadBid) -> 
          idAndCreationTimeStamp = elem(deadBid,0)
          durationInSec =  elem(deadBid,4)
          durationFixed = div (((durationInSec + 5) * 1000000000) - (System.system_time - idAndCreationTimeStam)), 1000000000 #calculo la diferencia de timestamps y le sumo 5 seg para la nueva duracion
          newDuration = :erlang.max(5,durationFixed) #revive con una duracion x default si ya murio

          :rpc.call(node,Bid.Supervisor,:add_bid,[elem(deadBid,0),elem(deadBid,3),newDuration,elem(deadBid,5),elem(deadBid,6)])
        end)
      end
    end)

    Process.send_after(self(), :check_nodes, 15000)

		{:noreply, loadBalancer}
  end
 
  def create_buyer(id, name, ip, interestedTags ) do
    workers = Enum.map(WorkerUtils.worker_nodes,fn (node) -> WorkerUtils.first_replica(node)[:node] end)
    node = List.first(Enum.take_random(workers,1))
    :rpc.call(node,Buyer.Supervisor,:add_buyer,[id, name, ip, interestedTags])
  end


  def handle_call({:create_buyer, id, name, ip, interestedTags }, _from, loadBalancer) do
    IO.puts("estoy distribuyendo")
    {response, pid} =  LoadBalancer.create_buyer(id, name, ip, interestedTags)
        
    if (response != :ok) do 
      {response, pid} =  LoadBalancer.create_buyer(id, name, ip, interestedTags)
    end
    IO.puts("cree")
    {:reply, {response,pid}, loadBalancer}
  end

  def create_bid(id, defaultPrice, duration, tags, item) do
    workers = Enum.map(WorkerUtils.worker_nodes,fn (node) -> WorkerUtils.first_replica(node)[:node] end)
    node = List.first(Enum.take_random(workers,1))
    :rpc.call(node,Bid.Supervisor,:add_bid,[ id, defaultPrice, duration, tags, item])
  end

  def handle_call({:create_bid, id, defaultPrice, duration, tags, item }, _from, loadBalancer) do
    IO.puts("estoy distribuyendo")
    {response, pid} = LoadBalancer.create_bid(id, defaultPrice, duration, tags, item)
        
    if (response != :ok) do 
      {response, pid} = LoadBalancer.create_bid(id, defaultPrice, duration, tags, item)
    end
    IO.puts("cree")
    {:reply, {response,pid}, loadBalancer}
  end

  
  def handle_call({:whereis, pid}, _from, loadBalancer) do
    workers = Enum.map(WorkerUtils.worker_nodes,fn (node) -> WorkerUtils.first_replica(node)[:node] end)
    
    node = Enum.find(workers,fn(worker) -> 
      response = :rpc.call(worker,GenServer,:call,[pid,:ping]) ## chequear si es {:ok,:pong} o solo :pong
      (response == :pong)  
    end)
    
   
    {:reply, node, loadBalancer}
	end

end