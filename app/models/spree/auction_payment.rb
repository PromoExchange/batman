class Spree::AuctionPayment < ActiveRecord::Base
  belongs_to :bid
  belongs_to :request_idea
end
