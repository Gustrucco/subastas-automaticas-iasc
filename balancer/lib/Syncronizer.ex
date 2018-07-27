defmodule Syncronizer do
	use GenServer

	def start_link(_arg) do
		GenServer.start_link(__MODULE__, %{nodes: []}, name: __MODULE__)
	end

	# SERVER
  
  def init(args) do
    Process.send(self(), :sync_dbs,[])
		{:ok, args}
  end

  def drop_first list do
  Enum.take(list,((length(list)-1) * (-1)))
  end

  def identity do
    :ets.fun2ms(fn t when true -> t end) 
  end
  
  def handle_info(:sync_dbs, syncronizer) do
      IO.puts("sincronizando")
      #agarro todos los nodes workers vivos y los hasheo
      workerNodes = Enum.map(WorkerUtils.worker_nodes(),fn(node) -> 
        WorkerUtils.node_to_node_token(node)
      end)
      
      #agarro todos los workers hasheados y los agrupo. Ejemplo de nodo  {node => :"worker-A-1@192.2.0", :id => "A", :num => 1}
      groupedWorkerNodes = Enum.group_by(workerNodes,fn(wkNode) ->
       wkNode[:id]
      end)
      
      Enum.each(Map.to_list(groupedWorkerNodes),fn {id, workerHashes} -> 
        allInstancesSorted = Enum.sort_by(workerHashes,fn(node) -> node[:num] end)
        actualNode = List.first(allInstancesSorted)[:node]
        IO.puts("nodo actual : #{Atom.to_string(actualNode)}")
      
        bids = List.flatten(:rpc.call(actualNode,:ets,:match,[:bids,:"$1"]))

        buyers =  List.flatten(:rpc.call(actualNode,:ets,:match,[:buyers,:"$1"]))
      
        replicaNodes = Syncronizer.drop_first(allInstancesSorted)
        
       
        Enum.each(replicaNodes,fn(replicaNode)-> #por cada replica node 
          Enum.each(bids,fn(row) -> 
            :rpc.call(replicaNode[:node],:ets,:insert,[:bids,row]) #replico los bids
          end)

          Enum.each(buyers,fn(row) -> 
            :rpc.call(replicaNode[:node],:ets,:insert,[:buyers,row]) #replico los buyers
          end)
      end)

      end)
    Process.send_after(self(), :sync_dbs, 15000)

		{:noreply, syncronizer}
  end 
end