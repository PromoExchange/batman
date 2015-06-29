class Spree::Auction < Spree::Base
  belongs_to :product
  belongs_to :buyer, class_name: 'Spree::User'
  has_many :bids
  has_one :order
  has_many :adjustments, as: :adjustable
  belongs_to :imprint_method
  has_and_belongs_to_many :pms_colors

  validates :product_id, presence: true
  validates :buyer_id, presence: true
  validates :quantity, presence: true

  def self.user_auctions
    Spree::Auctions.where(buyer_id: current_spree_user.id)
  end

  def lowest_bid
    bids.order('bid asc').first
  end
end
