defmodule LoadBalancer do
	use GenServer

	def start_link(_arg) do
		GenServer.start_link(__MODULE__, %{nodes: []}, name: __MODULE__)
	end

	
	# SERVER

  def init do
    Process.send(self(), :check_nodes,[])
  
		{:ok, []}
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
  def first_replica worker_hash do
    Enum.map(worker_hash,fn {key,value} -> List.first(Enum.sort_by(value,fn(node) -> node[:num] end)) end)
  end 
  
  def handle_info(:check_nodes, loadBalancer) do

    #agarro todos los nodes workers vivos y los hasheo
    workerNodes = Enum.map(WorkerUtils.worker_nodes(),fn(node) -> 
      WorkerUtils.node_to_node_token(node)
    end)
    
    #agarro todos los workers hasheados y los agrupo. Ejemplo de nodo  {node => :"worker-A-1@192.2.0", :id => "A", :num => 1}
    groupedWorkerNodes = Enum.group_by(workerNodes,fn(wkNode) ->
     wkNode[:id]
    end)
    #por cada grupo agarro
    Enum.each(groupedWorkerNodes,fn (workerHash) -> 
      firstReplica = WorkerUtils.first_replica(workerHash) #agarro la primera instancia de ese worker (que deberia ser la activa)
      node = firstReplica[:node]
     
      response = ''
      response = Node.ping node
      if(response != :pong) do #si no responde implicaria que es un nodo replica, no se estaba usando pero el que se estaba usando se cayo sino este no seria el primero del grupo
        identity = :ets.fun2ms fn t when true -> t end 
        deadBids = :rpc.call(node,:ets,:select,[:bids,identity])
        deadBuyers = :rpc.call(node,:ets,:select,[:buyers,identity]) 

        Enum.each(deadBuyers,fn(deadBuyer) ->  
           :rpc.call(node,Buyer.Supervisor,:add_buyer,[elem(deadBuyer,0),elem(deadBuyer,3),elem(deadBuyer,4),elem(deadBuyer,5)])
        end)
    
        Enum.each(deadBids,fn(deadBid) -> 
           :rpc.call(node,Bid.Supervisor,:add_bid,[elem(deadBid,0),elem(deadBid,3),elem(deadBid,4),elem(deadBid,5),elem(deadBid,6),elem(deadBid,7),elem(deadBid,8)])
        end)
      end
    end)

    Process.send_after(self(), :check_nodes, 15000)

		{:noreply, loadBalancer}
  end
 
  #no estoy seguro de si esto funciona parametrizando funciones 
	def handle_call({:distribute, function}, _from, loadBalancer) do
    workers = Enum.map(WorkerUtils.worker_nodes,fn (node) -> WorkerUtils.first_replica(node)[:node] end)
    node = Enum.take_random(workers,1)
    {response, pid} = function.(node) #no estoy seguro de si se puede llamar asi
   
    if (response != :ok) do 
     GenServer.call(self(),{:distribute,function})
    end
   
    {:reply, {response,pid}, loadBalancer}
  end
  
  def handle_call({:whereis, pid}, _from, loadBalancer) do
    workers = Enum.map(WorkerUtils.worker_nodes,fn (node) -> WorkerUtils.first_replica(node)[:node] end)
    
    node = Enum.find(workers,fn(worker) -> 
      response = :rpc.call(worker,GenServer,:call,[:ping]) ## chequear si es {:ok,:pong} o solo :pong
      (response == :pong)  
    end)
    
   
    {:reply, node, loadBalancer}
	end

end