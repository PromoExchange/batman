class Spree::AuctionsUser < Spree::Base
  belongs_to :auction
  belongs_to :user

  validates :auction_id, presence: true
  validates :user_id, presence: true
end
