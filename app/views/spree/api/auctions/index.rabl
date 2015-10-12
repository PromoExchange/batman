collection @auctions
attributes(*auction_attributes)
child winning_bid: :winning_bid do
  attributes(*bid_attributes)
end
child bids: :bids do
  attributes(*bid_attributes)
end
child invited_sellers: :invited_sellers do
  attributes(*user_attributes)
end
child review: :review do
  attributes(*review_attributes)
end