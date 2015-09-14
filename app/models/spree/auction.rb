class Spree::Auction < Spree::Base
  scope :open, -> { where(status: :open) }
  scope :waiting, -> { where(status: :waiting) }
  scope :closed, -> { where(status: :closed) }
  scope :ended, -> { where(status: :ended) }
  scope :cancelled, -> { where(status: :cancelled) }

  before_create :set_default_dates
  after_create :generate_reference

  has_many :adjustments, as: :adjustable
  has_many :bids, -> { includes(:order).order('spree_orders.total ASC') }

  has_many :auctions_users, class_name: 'Spree::AuctionsUser'
  has_many :invited_sellers, through: :auctions_users, source: :user

  belongs_to :buyer, class_name: 'Spree::User'
  belongs_to :imprint_method
  belongs_to :logo
  belongs_to :main_color, class_name: 'Spree::ColorProduct'
  has_one :order

  has_many :auctions_pms_colors, class_name: 'Spree::AuctionPmsColor'
  has_many :pms_colors, through: :auctions_pms_colors

  belongs_to :product
  belongs_to :shipping_address, class_name: 'Spree::Address'

  accepts_nested_attributes_for :auctions_pms_colors

  validates :buyer_id, presence: true
  validates :logo_id, presence: true, unless: -> do
    imprint_method = Spree::ImprintMethod.where(name: 'Blank').first
    return true if imprint_method.nil? # Needed for testing, do not seed db:test
    imprint_method_id == imprint_method.id
  end
  validates :main_color_id, presence: true
  validates_inclusion_of :payment_method, in: ['Credit Card', 'Check']
  validates :product_id, presence: true
  validates :imprint_method_id, presence: true
  validates :quantity, presence: true
  validates_inclusion_of :status, in: %w(open waiting closed ended cancelled unpaid completed)
  validates :shipping_address_id, presence: true
  validates_numericality_of :quantity, only_integer: true
  validates_numericality_of :quantity, greater_than_or_equal_to: -> (auction) do
    50 if auction.product.nil?
    auction.product.minimum_quantity
  end

  state_machine initial: :open do
    event :end do
      transition open: :ended
    end

    event :cancel do
      transition open: :cancelled
    end

    event :accept do
      transition open: :waiting_confirmation
    end

    event :confirm do
      transition waiting_confirmation: :order_confirmed
    end

    event :late_confirm do
      transition waiting_confirmation: :order_lost
    end

    event :in_production do
      transition order_confirmed: :in_production
    end

    event :enter_tracking do
      transition in_production: :confirm_receipt
    end

    event :enter_tracking do
      transition in_production: :confirm_receipt
    end

    event :confirm_shipment do
      transition confirm_receipt: :waiting_for_rating
    end

    event :rate_seller do
      transition waiting_for_rating: :complete
    end
  end

  delegate :name, to: :product

  def self.user_auctions
    Spree::Auctions.where(buyer_id: current_spree_user.id)
  end

  def image_uri
    product.images.empty? ? 'noimage/mini.png' : product.images.first.attachment.url('mini')
  end

  def product_unit_price
    unit_price = product.price
    product.master.volume_prices.each do |v|
      if v.open_ended? || (v.range.to_range.begin..v.range.to_range.end).include?(quantity)
        unit_price = v.amount
        break
      end
    end
    unit_price
  end

  def num_locations
    1
  end

  def num_colors
    pms_colors.count
  end

  def rush?
    false
  end

  def preferred?(seller)
    auctions_users.where(user: seller).first.nil? ? false : true
  end

  def buyer_email
    Spree::User.find(buyer_id).email
  end

  def winning_bid
    Spree::Bid.where(auction_id: id, status: %w(accepted completed)).first
  end

  def set_default_dates
    self.started = Time.zone.now
    self.ended = started + 21.days
  end

  def generate_reference
    update_column :reference, SecureRandom.hex(3).upcase
  rescue ActiveRecord::RecordNotUnique => e
    @reference_attempts ||= 0
    @reference_attempts += 1
    retry if @reference_attempts < 5
    raise e, 'Retries exhausted'
  end
end
