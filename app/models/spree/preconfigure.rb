class Spree::Preconfigure < Spree::Base
  after_save :clear_cache

  belongs_to :product
  belongs_to :buyer, class_name: 'Spree::User'
  belongs_to :imprint_method
  belongs_to :main_color, class_name: 'Spree::ColorProduct'
  belongs_to :logo

  validates :product_id, presence: true
  validates :buyer_id, presence: true
  validates :imprint_method_id, presence: true
  validates :main_color_id, presence: true
  validates :logo_id, presence: true
  validates :primary, presence: true

  # TODO: Add validation so we only have 1 primiary configuration

  delegate :clear_cache, to: :product

  def best_price_params
    {
      quantity: 1,
      shipping_address: buyer.shipping_address,
      shipping_option: :ups_ground
    }
  end
end
