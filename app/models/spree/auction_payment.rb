class Spree::AuctionPayment < ActiveRecord::Base
  belongs_to :bid
  belongs_to :request_idea

  validates :bid_id, presence: true
end
