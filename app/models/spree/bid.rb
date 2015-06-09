class Spree::Bid < Spree::Base
  belongs_to :auction
  belongs_to :seller, class_name: 'Spree::User'
  belongs_to :order
  belongs_to :prebid

  validates :auction_id, presence: true
  validates :seller_id, presence: true
  validates :bid, presence: true
  # TODO: Add constraint once dust settles
  # validates :order_id, presence: true
end
