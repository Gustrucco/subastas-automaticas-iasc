defmodule SubastasAutomaticas do
  @moduledoc """
  Documentation for SubastasAutomaticas.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SubastasAutomaticas.hello
      :world

  """
  use GenServer
  
 
  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def add_message(pid, message) do
    GenServer.cast(pid, {:add_message, message})
  end

  def get_messages(pid) do
    GenServer.call(pid, :get_messages)
  end

  # SERVER

  def init(messages) do
    {:ok, {messages,4}}
  end

  def handle_cast({:add_message, new_message}, messages) do
    {:noreply, [new_message | messages]}
  end

  def handle_call(:get_messages, _from, {messages,unit}) do
    {:reply, {messages,unit + 1}, {messages,unit + 1}}
  end

  def hello do
    IO.puts "saraza"
  end
end

