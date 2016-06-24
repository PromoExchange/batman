class Spree::Quote < Spree::Base
  include QuoteCalculator

  belongs_to :main_color, class_name: 'Spree::ColorProduct'
  belongs_to :shipping_address, class_name: 'Spree::Address'
  belongs_to :imprint_method
  has_many :shipping_options, dependent: :destroy

  # Assumes products are not shared across company stores
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

  attr_reader :messages

  def total_price(options = {})
    options.reverse_merge!(
      shipping_option: Spree::ShippingOption::OPTION[:ups_ground]
    )

    # Cache the price
    # TODO: Add expiration env/config
    Rails.cache.fetch("#{cache_key}/total_price", expires_in: 12.hours) do
      best_price(options)
    end
  end

  def cache_key
    "spree/quote/#{product.id}/#{quantity}/#{shipping_option.id}"
  end

  def log(message)
    @messages ||= []
    @messages << message
  end

  private

  def best_price(_options = {})
    100.00
  end
end
