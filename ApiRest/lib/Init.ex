defmodule InitWorker do  

  def start_worker do
    IO.puts "** Arrancuti **"
    DataBase.start_link(:ok)
    DataBase.init()
    #ApiRest.Supervisor.start_link
    children = [
      {Buyer.Supervisor, :implicit_arg},
      {Bid.Supervisor, :implicit_arg},
      {BuyerNotifier.Supervisor, :implicit_arg}
    ]
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end