defmodule WorkerUtils do
	
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

  {k,value} = Enum.find(Map.to_list(groupedWorkerNodes),fn ({id,value}) -> id == hashNode[:id] end)
  List.first(Enum.sort_by(value,fn(node) -> node[:num] end))
  end 
  
end