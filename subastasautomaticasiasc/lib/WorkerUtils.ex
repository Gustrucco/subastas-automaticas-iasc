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
  
  def to_all_notifier function do
    workers = Enum.map(WorkerUtils.worker_nodes,fn(node) -> 
      WorkerUtils.first_replica(WorkerUtils.node_to_node_token(node))[:node]
    end)
    Enum.each(workers,fn(worker) -> 
    notifier = :rpc.call(worker,Process,:whereis,[BuyerNotifier])
    function.(notifier)
    end)  
  end

  def match_in_all_workers table, matcher do
    workers = Enum.map(WorkerUtils.worker_nodes,fn(node) -> 
      WorkerUtils.first_replica(WorkerUtils.node_to_node_token(node))[:node]
    end)
    matched = Enum.map(workers,fn (worker) -> 
      :rpc.call(worker,:ets,:match,[table, matcher])
    end)
    List.flatten(matched)
  end

  def lookup_in_all_workers table, id do
    workers = Enum.map(WorkerUtils.worker_nodes,fn(node) -> 
      WorkerUtils.first_replica(WorkerUtils.node_to_node_token(node))[:node]
    end)
    finded = Enum.map(workers,fn (worker) -> 
      :rpc.call(worker,:ets,:lookup,[table, id])
    end)
    List.flatten(finded)
  end
end