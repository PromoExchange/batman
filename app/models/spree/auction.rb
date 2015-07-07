class Spree::Auction < Spree::Base
  belongs_to :product
  belongs_to :buyer, class_name: 'Spree::User'
  has_many :bids
  has_one :order
  belongs_to :shipping_address, class_name: 'Spree::Address'
  has_many :adjustments, as: :adjustable
  belongs_to :imprint_method
  belongs_to :main_color, class_name: 'Spree::ColorProduct'

  has_many :pms_colors, class_name: 'Spree::AuctionPmsColor'
  accepts_nested_attributes_for :pms_colors

  validates :product_id, presence: true
  validates :buyer_id, presence: true
  validates :quantity, presence: true
  validates :main_color_id, presence: true
  validates :shipping_address_id, presence: true
  validates :payment_method, presence: true
  validates_inclusion_of :payment_method, :in => ['Credit Card','Check']

  def self.user_auctions
    Spree::Auctions.where(buyer_id: current_spree_user.id)
  end

  def lowest_bid
    # TODO: Sort by association
    lowest_bid = nil
    lowest_bid_value = 1.0 / 0
    bids.each do |b|
      unless lowest_bid_value < b.bid
        lowest_bid_value = b.bid
        lowest_bid = b.id
      end
    end
    lowest_bid
  end
end
