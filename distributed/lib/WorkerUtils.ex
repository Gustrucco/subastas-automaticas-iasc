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
  
  def first_replica worker_hash do
    Enum.map(worker_hash,fn {key,value} -> List.first(Enum.sort_by(value,fn(node) -> node[:num] end)) end)
  end 
  
end