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
  belongs_to :buyer, class_name: 'Spree::User'
  belongs_to :imprint_method
  belongs_to :main_color, class_name: 'Spree::ColorProduct'
  has_one :order
  has_many :auctions_pms_colors, class_name: 'Spree::AuctionPmsColor'
  has_many :pms_colors, through: :auctions_pms_colors
  belongs_to :product
  belongs_to :shipping_address, class_name: 'Spree::Address'

  accepts_nested_attributes_for :auctions_pms_colors

  validates :buyer_id, presence: true
  validates :main_color_id, presence: true
  validates_inclusion_of :payment_method, in: ['Credit Card', 'Check']
  validates :product_id, presence: true
  validates :quantity, presence: true
  validates_inclusion_of :status, in: %w(open waiting closed ended cancelled)
  validates :shipping_address_id, presence: true

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
