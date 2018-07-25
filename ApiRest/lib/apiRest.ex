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
        {rsp, pid} = GenServer.call(BalancerUtils.balancer_pid(),{
          :create_buyer,
          id, params[:name], 
          params[:ip], 
          params[:interestedTags]
        }
      )
        if rsp == :ok do
          json(conn, "Created buyer #{id}")
        else
          IO.puts(rsp)
          json(conn, "Fallo")  
        end
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
      {rsp, pid} = GenServer.call(BalancerUtils.balancer_pid(),{
          :create_bid,
          id,
          params[:defaultPrice], 
          params[:duration], 
          params[:tags], 
          params[:item]
        }
      )
      IO.puts(rsp)
      if rsp == :ok do
      json(conn, "Created bid #{id}")
      else
        json(conn, "Fallo")  
      end
    end

    route_param :bidId do
      namespace :offer do
        params do
          requires :buyerName, type: Integer
          requires :offer, type: Float
        end
        post do
          offerPerson = params[:buyerName]
          IO.puts "New offer by #{offerPerson} for #{params[:offer]}"
<<<<<<< 20b03f0203bb6f24f8dd81b667d4b0dc9babfbfe
          matchingBuyers = :ets.match(:buyers, { offerPerson, :"_", :"_", :"_", :"_", :"_"})
=======
          matchingBuyers = WorkerUtils.match_in_all_workers(:buyers, { :"_", :"_", :"_", :"_", offerPerson, :"_"})
>>>>>>> subido mergeo
          if matchingBuyers != [] do
            {bidId, _} = Integer.parse(params[:bidId])
            {_, pid, _, _, _, _, _, actualPrice, _, hasFinished} = Enum.at(WorkerUtils.lookup_in_all_workers(:bids, bidId),0)
            if !hasFinished do
              if params[:offer] > actualPrice do
                GenServer.cast(pid, {:new_offer, params[:offer], offerPerson})
                json(conn, "New winner #{offerPerson} in bid #{params[:bidId]} with the ammount of #{params[:offer]}")
              else
                conn |> put_status(409) |> text("Sorry #{offerPerson}, bid #{params[:bidId]} price is #{actualPrice}. You must offer higher to win")
              end
            else
              conn |> put_status(409) |> text("Sorry #{offerPerson}, bid #{params[:bidId]} finished")
            end
          else
            conn |> put_status(404) |> text("Sorry #{offerPerson}, we couldn't find you in our system")
          end
        end
      end

      namespace :cancel do
        post do
          {bidId, _} = Integer.parse(params[:bidId])
          pid = elem(Enum.at(WorkerUtils.lookup_in_all_workers(:bids, bidId),0),1)
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