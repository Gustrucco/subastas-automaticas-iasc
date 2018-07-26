defmodule WorkerUtils do

  def worker_nodes do
    Enum.filter((Node.list ++ [Node.self()]),
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
  
  def first_replica node do
    hashNode = WorkerUtils.node_to_node_token(node)
      #agarro todos los nodes workers vivos y los hasheo
    workerNodes = Enum.map(WorkerUtils.worker_nodes(),fn(node) -> 
      WorkerUtils.node_to_node_token(node)
    end)
    
    #agarro todos los workers hasheados y los agrupo. Ejemplo de nodo  {node => :"worker-A-1@192.2.0", :id => "A", :num => 1}
    groupedWorkerNodes = Enum.group_by(workerNodes,fn(wkNode) ->
      wkNode[:id]
    end)

  {k,value} = Enum.find(Map.to_list(groupedWorkerNodes),fn {id,value} -> id == hashNode[:id] end)
  List.first(Enum.sort_by(value,fn(node) -> node[:num] end))
  end 
  
  def to_all_notifier function do
    workerNodes = Enum.map(WorkerUtils.worker_nodes(),fn(node) -> 
      WorkerUtils.node_to_node_token(node)
    end)
    
    #agarro todos los workers hasheados y los agrupo. Ejemplo de nodo  {node => :"worker-A-1@192.2.0", :id => "A", :num => 1}
    groupedWorkerNodes = Enum.group_by(workerNodes,fn(wkNode) ->
      wkNode[:id]
    end)

    allFirstReplicas = Enum.map(Map.to_list(groupedWorkerNodes),
    fn {id,value} -> 
      List.first(Enum.sort_by(value,fn(aNode) -> aNode[:num] end))[:node]
    end)
    
    Enum.each(allFirstReplicas, fn(worker) -> 
    notifier = :rpc.call(worker,Process,:whereis,[BuyerNotifier])
    IO.puts("avisandole a #{Atom.to_string(worker)} en #{:erlang.pid_to_list(notifier)}")
    function.(notifier)
    end)  
  end

  def match_in_all_workers table, matcher do
    workerNodes = Enum.map(WorkerUtils.worker_nodes(),fn(node) -> 
      WorkerUtils.node_to_node_token(node)
    end)
    
    #agarro todos los workers hasheados y los agrupo. Ejemplo de nodo  {node => :"worker-A-1@192.2.0", :id => "A", :num => 1}
    groupedWorkerNodes = Enum.group_by(workerNodes,fn(wkNode) ->
      wkNode[:id]
    end)

    allFirstReplicas = Enum.map(Map.to_list(groupedWorkerNodes),
    fn {id,value} -> 
      List.first(Enum.sort_by(value,fn(aNode) -> aNode[:num] end))[:node]
    end)

    matched = Enum.map(allFirstReplicas,fn (worker) -> 
      :rpc.call(worker,:ets,:match,[table, matcher])
    end)
    matched
  end

  def lookup_in_all_workers table, id do
    workerNodes = Enum.map(WorkerUtils.worker_nodes(),fn(node) -> 
      WorkerUtils.node_to_node_token(node)
    end)
    
    #agarro todos los workers hasheados y los agrupo. Ejemplo de nodo  {node => :"worker-A-1@192.2.0", :id => "A", :num => 1}
    groupedWorkerNodes = Enum.group_by(workerNodes,fn(wkNode) ->
      wkNode[:id]
    end)

    allFirstReplicas = Enum.map(Map.to_list(groupedWorkerNodes),
    fn {id,value} -> 
      List.first(Enum.sort_by(value,fn(aNode) -> aNode[:num] end))[:node]
    end)

    finded = Enum.map(allFirstReplicas,fn (worker) -> 
      :rpc.call(worker,:ets,:lookup,[table, id])
    end)
    List.flatten(finded)
  end
end