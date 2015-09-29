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
  validates :shipping_address_id, presence: true
  validates_numericality_of :quantity, only_integer: true
  validates_numericality_of :quantity, greater_than_or_equal_to: -> (auction) do
    50 if auction.product.nil?
    auction.product.minimum_quantity
  end

  # preferred
  #   open
  #   accept -> unpaid
  #   preferred_pay -> complete

  # non preferred
  #   open
  #   accept -> waiting_confirmation
  #   confirm -> order_confirmed
  #   enter_tracking -> confirm_receipt
  #   confirm_receipt -> complete
  #
  #   non_preferred_pay -> as before

  #   rate, any time, not really a state
  #   cancel, only valid before accept
  #   end, At the end of the auctions time

  state_machine initial: :open do
    after_transition on: :confirm_order, do: :notification_for_in_production
    after_transition on: :delivered, do: :notification_for_product_delivered

    # TODO: When auction created, schedule job to end it
    event :end do
      transition open: :ended
    end

    event :cancel do
      transition [:open, :waiting_confirmation] => :cancelled
    end

    event :accept do
      transition open: :waiting_confirmation
    end

    # Technically this is accept for preferred sellers
    event :unpaid do
      transition [:open, :waiting_confirmation] => :unpaid
    end

    event :invoice_paid do
      transition unpaid: :waiting_confirmation
    end

    event :confirm_order do
      transition waiting_confirmation: :in_production
    end

    event :enter_tracking do
      transition in_production: :send_for_delivery
    end

    event :delivered do
      transition send_for_delivery: :confirm_receipt
    end

    event :delivery_confirmed do
      transition confirm_receipt: :complete
    end
  end

  delegate :name, to: :product

  def notification_for_in_production
    Resque.enqueue(
      InProduction,
      auction_id: id
    )
  end

  def notification_for_product_delivered
    Resque.enqueue(
      ProductDelivered,
      auction_id: id
    )
  end

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

  def buyer_company
    buyer = Spree::User.find(buyer_id)
    return '' unless buyer.shipping_address
    Spree::User.find(buyer_id).shipping_address.company
  end

  def winning_bid
    Spree::Bid.where(auction_id: id, state: %w(accepted completed waiting_confirmation)).first
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
