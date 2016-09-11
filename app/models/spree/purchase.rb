class Spree::Purchase < Spree::Base
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
  validates :price_breaks, presence: true
  validates :shipping_option, presence: true

  belongs_to :order

  def self.sizes
    %w(S M L XL 2XL)
  end
end
