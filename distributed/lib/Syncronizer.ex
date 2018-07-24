defmodule Syncronizer do
	use GenServer

	def start_link(_arg) do
		GenServer.start_link(__MODULE__, %{nodes: []}, name: __MODULE__)
	end

  def init do
    Process.send(self(), :sync_dbs,[])

		{:ok, []}
  end
  
	# SERVER
  def init(args) do
    {:ok, args}
  end
  
  def drop_first list do
  Enum.take(list,((length(list)-1) * (-1)))
  end

  def handle_info(:sync_dbs, syncronizer) do
      #agarro todos los nodes workers vivos y los hasheo
      workerNodes = Enum.map(WorkerUtils.worker_nodes(),fn(node) -> 
        WorkerUtils.node_to_node_token(node)
      end)
      
      #agarro todos los workers hasheados y los agrupo. Ejemplo de nodo  {node => :"worker-A-1@192.2.0", :id => "A", :num => 1}
      groupedWorkerNodes = Enum.group_by(workerNodes,fn(wkNode) ->
       wkNode[:id]
      end)
      
      Enum.each(groupedWorkerNodes,fn {id, workerHashes} -> 
        actualNode = List.first(workerHashes)[:node] #agarro el nod actual
        identity = :ets.fun2ms fn t when true -> t end 
        
        bids = :rpc.call(actualNode,:etc,:select,[:bids,identity]) # agarro su coleccion de bids
        
        buyers = :rpc.call(actualNode,:etc,:select,[:buyers,identity]) # agarro su coleccion de buyers
        
        replicaNodes = Syncronizer.drop_first(workerHashes)
        
        Enum.each(replicaNodes,fn(replicaNode)-> #por cada replica node 
          Enum.each(bids,fn(row) -> 
            :rpc.call(node,:etc,:insert,[:bids,row]) #replico los bids
          end)

          Enum.each(buyers,fn(row) -> 
            :rpc.call(node,:etc,:insert,[:buyers,row]) #replico los buyers
          end)
      end)

      end)
    Process.send_after(self(), :sync_dbs, 15000)

		{:noreply, syncronizer}
  end 
end