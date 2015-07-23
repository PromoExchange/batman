object @auction
attributes(*auction_attributes)
child bids: :bids do
  attributes(*bid_attributes)
end
