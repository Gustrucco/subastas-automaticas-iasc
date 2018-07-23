  defmodule Router.Buyers do
    use Maru.Router
  
    namespace :buyers do
      params do
        requires :name, type: String
        requires :ip, type: String
        requires :interestedTags, type: List[String] , keep_blank: true
      end
  
      post do
        id = System.system_time()
        Buyer.Supervisor.add_buyer(id, params[:name], params[:ip], params[:interestedTags])
        json(conn, "Created buyer #{id}")
      end
    end
  end

defmodule Router.Bids do
  use Maru.Router
  use GenServer

  namespace :bids do

    params do
      requires :defaultPrice, type: Float
      requires :duration, type: Integer
      requires :tags, type: List[String] , keep_blank: true
      requires :item, type: Map, keep_blank: true
    end

    post do
      id = System.system_time()
      Bid.Supervisor.add_bid(id, params[:defaultPrice], params[:duration], params[:tags], params[:item])
      json(conn, "Created bid #{id}")
    end

    route_param :bidId do
      namespace :offer do
        params do
          requires :buyerName, type: String
          requires :offer, type: Float
        end
        post do
          offerPerson = params[:buyerName]
          IO.puts "New offer by #{offerPerson} for #{params[:offer]}"
          matchingBuyers = :ets.match(:buyers, { :"_", :"_", :"_", :"_", offerPerson, :"_"})
          if matchingBuyers != [] do
            {bidId, _} = Integer.parse(params[:bidId])
            {_, pid, _, _, _, _, _, actualPrice, _, _} = Enum.at(:ets.lookup(:bids, bidId),0)
            if params[:offer] > actualPrice do
              GenServer.cast(pid, {:new_offer, params[:offer], offerPerson})
              json(conn, "New winner #{offerPerson} in bid #{params[:bidId]} with the ammount of #{params[:offer]}")
            else
              json(conn, "Sorry #{offerPerson}, bid #{params[:bidId]} price is #{actualPrice}. You must offer higher to win")
            end
          else
            json(conn, "Sorry #{offerPerson}, we couldn't find you in our system")
          end
        end
      end

      namespace :cancel do
        post do
          {bidId, _} = Integer.parse(params[:bidId])
          pid = elem(Enum.at(:ets.lookup(:bids, bidId),0),1)
          GenServer.cast(pid, :cancel)
          json(conn, "Canceled bid #{params[:bidId]}")
        end
      end
    end
  end
end
  
  
  defmodule Router.Homepage do
    use Maru.Router
  
    resources do
      mount Router.Buyers
      mount Router.Bids
    end
  end
  
  
  defmodule MyAPP.API do
    use Maru.Router
  
    def start_link(:ok) do
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
  
    plug Plug.Parsers,
      pass: ["*/*"],
      json_decoder: Jason,
      parsers: [:urlencoded, :json, :multipart]
  
    mount Router.Homepage
  
    rescue_from Unauthorized, as: e do
      IO.inspect e
  
      conn
      |> put_status(401)
      |> text("Unauthorized")
    end
  
    rescue_from [MatchError, RuntimeError], with: :custom_error
  
    rescue_from :all, as: e do
      conn
      |> put_status(Plug.Exception.status(e))
      |> text("Server Error")
    end
  
    defp custom_error(conn, exception) do
      conn
      |> put_status(500)
      |> text(exception.message)
    end
  end