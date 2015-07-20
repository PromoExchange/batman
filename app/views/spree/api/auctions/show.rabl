object @auction
attributes *auction_attributes
child lowest_bids: :lowest_bids do
  attributes *bid_attributes
end
