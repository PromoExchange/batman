class Spree::Quote < Spree::Base
  belongs_to :main_color, class_name: 'Spree::ColorProduct'
  belongs_to :shipping_address, class_name: 'Spree::Address'
  belongs_to :imprint_method
  belongs_to :product

  validates :main_color, presence: true
  validates :product, presence: true
  validates :shipping_address, presence: true
  validates :imprint_method, presence: true
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: (lambda do |quote|
      50 if quote.product.nil?
      quote.product.minimum_quantity
    end)
  }
end
