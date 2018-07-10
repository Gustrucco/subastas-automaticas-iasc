
use Amnesia
#for further information go to https://github.com/meh/amnesia
defdatabase Database do

  deftable Bid, [{ :id, autoincrement }, :tags, :defaultPrice, :duration, :item, :buyerNotifier, :actualPrice, :actualWinner], type: :bag do end

  deftable Buyer, [{ :id, autoincrement }, :name, :ip, :duration, :interestedTags], type: :set do end

end