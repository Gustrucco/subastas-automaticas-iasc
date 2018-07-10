  defmodule Router.Buyers do
    use Maru.Router
  
    namespace :buyers do
  
      params do
        requires :name, type: String
        requires :ip, type: String
        requires :interestedTags, type: List[String] , keep_blank: true
      end
  
      post do
        Buyer.Supervisor.add_buyer(params[:name], params[:ip], params[:interestedTags])
        json(conn, "Buyer Creado")
      end
    end
  end
  
  defmodule Router.Bids do
    use Maru.Router
  
    namespace :bids do
  
      params do
        requires :defaultPrice, type: Float
        requires :duration, type: Integer
        requires :tags, type: List[String] , keep_blank: true
        requires :item, type: Map, keep_blank: true
      end
  
      post do
        #El ultimo parametro tiene que ser el buyerNotifier
        Bid.Supervisor.add_bid(params[:tags], params[:defaultPrice], params[:duration], params[:item], :ok)
        json(conn, "creado")
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
      IO.puts "** Arranqueti **"
      Buyer.Supervisor.start_link(:ok)
      Bid.Supervisor.start_link(:ok)
      BuyerNotifier.Supervisor.start_link

      #ApiRest.Supervisor.start_link
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