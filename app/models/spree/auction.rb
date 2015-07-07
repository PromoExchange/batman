class Spree::Auction < Spree::Base
  scope :open, -> { where(status: :open) }
  scope :waiting, -> { where(status: :waiting) }
  scope :closed, -> { where(status: :closed) }
  scope :ended, -> { where(status: :ended) }
  scope :cancelled, -> { where(status: :cancelled) }

  has_many :adjustments, as: :adjustable
  has_many :bids
  belongs_to :buyer, class_name: 'Spree::User'
  belongs_to :imprint_method
  belongs_to :main_color, class_name: 'Spree::ColorProduct'
  has_one :order
  has_many :pms_colors, class_name: 'Spree::AuctionPmsColor'
  belongs_to :product
  belongs_to :shipping_address, class_name: 'Spree::Address'

  accepts_nested_attributes_for :pms_colors

  validates :buyer_id, presence: true
  validates :main_color_id, presence: true
  validates_inclusion_of :payment_method, in: ['Credit Card','Check']
  validates :product_id, presence: true
  validates :quantity, presence: true
  validates_inclusion_of :status, in: %w(open waiting closed ended cancelled)
  validates :shipping_address_id, presence: true

  def self.user_auctions
    Spree::Auctions.where(buyer_id: current_spree_user.id)
  end

  def lowest_bid
    lowest_bid = nil
    lowest_bid_value = BigDecimal.new(-1,4)
    bids.each do |b|
      unless lowest_bid_value == -1 || lowest_bid_value < b.bid
        lowest_bid_value = b.bid
        lowest_bid = b.id
      end
    end
    lowest_bid
  end
end
