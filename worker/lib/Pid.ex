defmodule Pid do
  def pid_tokens(aPid) do
    pidStr = :erlang.pid_to_list(aPid)
    pidStr1 = :lists.sublist(pidStr, 2, length(pidStr)-2)
    [a,b,c] = :string.lexemes(pidStr1,'.')
    {a,b,c}
  end

  def tokens_to_pid({token1,token2,token3}) do
  :erlang.list_to_pid('<' ++ token1 ++ '.' ++ token2 ++ '.' ++ token3 ++ '>')
  end

  def node_token(node) do 
    aPid = []
    if (node != Node.self()) do
    aPid = List.first(:rpc.call(node,Process,:list,[]))
    else
      IO.puts("otro Aca")
      otherNode = Enum.find(Node.list(),fn(aNode) -> aNode != node end)
      aPid = List.first(:rpc.call(otherNode,Pid,:node_token,[node]))
    end
    {nodeToken,_,_} = pid_tokens(aPid)
    nodeToken
  end

  def a_pid do
  List.first(Process.list)
  end

  def your_token do
    aPid = :rpc.call(List.first(Node.list),Pid,:a_pid,[])
    {token,_,_} = Pid.pid_tokens(aPid)
    token
  end

  def your_pid?(aPid) do
    {a,b,c} = Pid.pid_tokens(aPid)
    a  == '0'
  end

  def my_token do
    :rpc.call(List.first(Node.list),Pid,:your_token,[])
  end

  def pid_to_my_external_token pid do
    {_,tk1,tk2} = Pid.pid_tokens(pid)
    {Pid.my_token(), tk1, tk2}
  end
end
