class Spree::Purchase < Spree::Base
  belongs_to :product
  # TODO: Remove:
  # - logo
  # - imprint_method
  # - main_color
  # - buyer
  # Delegate through product or CS
  belongs_to :logo
  belongs_to :imprint_method
  belongs_to :main_color, class_name: 'Spree::ColorProduct', foreign_key: 'main_color_id'
  belongs_to :buyer, class_name: 'Spree::User'
  belongs_to :address, class_name: 'Spree::Address'
  belongs_to :order, dependent: :destroy
  has_one :image, as: :viewable, dependent: :destroy, class_name: 'Spree::Image'

  # TODO: remove reference, moved to purchase
  after_create :generate_reference

  attr_accessor :price_breaks,
    :sizes,
    :ship_to_zip,
    :custom_pms_colors

  validates :quantity, presence: true
  validates :product_id, presence: true
  validates :logo_id, presence: true
  validates :imprint_method_id, presence: true
  validates :main_color_id, presence: true
  validates :buyer_id, presence: true
  validates :shipping_option, presence: true
  validates :address_id, presence: true

  def self.sizes
    %w(S M L XL 2XL)
  end

  def seller_fee
    return 0.0 if order.nil?
    (order.total * 0.0899).round(2)
  end

  private

  def generate_reference
    update_column :reference, SecureRandom.hex(3).upcase
  rescue ActiveRecord::RecordNotUnique => e
    @reference_attempts ||= 0
    @reference_attempts += 1
    retry if @reference_attempts < 5
    raise e, 'Retries exhausted'
  end
end
