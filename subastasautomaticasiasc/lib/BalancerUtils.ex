defmodule BalancerUtils do
	
  def get_balancer_node do
    List.first(Enum.filter(Node.list,
      fn(node)-> Regex.match?(~r/balancer/,Atom.to_string(node))
      end)
    )
  end
end