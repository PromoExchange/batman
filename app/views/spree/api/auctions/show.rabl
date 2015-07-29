object @auction
attributes(*auction_attributes)
child winning_bid: :winning_bid do
  attributes(*bid_attributes)
end
child bids: :bids do
  attributes(*bid_attributes)
end
