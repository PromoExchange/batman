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
  belongs_to :order

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
end
