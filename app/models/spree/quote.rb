class Spree::Quote < Spree::Base
  include QuoteCalculator

  # TODO: remove reference, moved to purchase
  after_create :generate_reference

  belongs_to :main_color, class_name: 'Spree::ColorProduct'
  belongs_to :shipping_address, class_name: 'Spree::Address'
  has_many :shipping_options, dependent: :destroy
  has_many :pms_colors

  # TODO: Fix association between quote and product
  # Assumes products are not shared across company stores
  belongs_to :product

  attr_writer :messages
  attr_writer :cache_expiration
  attr_writer :write_log
  attr_writer :num_locations
  attr_writer :px_commission_rate
  attr_writer :payment_processing_commission
  attr_writer :payment_processing_flat_fee
  attr_writer :error_code

  def messages
    @messages ||= []
  end

  def error_code
    @error_code ||= :no_error
  end

  def cache_expiration
    @cache_expiration || 12
  end

  def write_log
    @write_log || true
  end

  def fixed_price_delivery_days
    @fixed_price_delivery_days || 7
  end

  def num_locations
    # TODO: Move to product
    @num_locations || 1
  end

  def px_commission_rate
    @px_commission || 0.0899
  end

  def payment_processing_commission
    @payment_processing_commission || 0.029
  end

  def payment_processing_flat_fee
    @payment_processing_flat_fee || 0.30
  end

  validates :main_color, presence: true
  validates :product, presence: true
  validates :selected_shipping_option, presence: true
  validates :shipping_address, presence: true
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: (lambda do |quote|
      return 50 if quote.product.nil?
      quote.product.minimum_quantity
    end)
  }
  validates_associated :product
  validates_associated :main_color
  validates_associated :shipping_address
  validates_associated :pms_colors

  delegate :company_store, to: :product
  delegate :markup, to: :product
  delegate :imprint_method, to: :product

  def selected_shipping
    shipping_options.find_by_shipping_option(selected_shipping_option)
  end

  def total_price(options = {})
    options.reverse_merge!(
      selected_shipping_option: :ups_ground
    )
    self.selected_shipping_option = Spree::ShippingOption::OPTION[options[:selected_shipping_option]]

    log("Total price called #{options}")
    from_cache = true
    best_price = Rails.cache.fetch("#{cache_key}/total_price", expires_in: cache_expiration.hours) do
      from_cache = false
      best_price(options)
    end
    log("Retrieved from cache [#{from_cache}]")
    best_price
  end

  def cache_key(shipping_option = nil)
    shipping_option ||= selected_shipping_option
    "#{model_name.cache_key}/#{product.id}/#{shipping_option}/#{quantity}"
  end

  def log(message)
    messages << message if write_log == true
  end

  def num_colors
    standard_color_color = pms_colors.count
    custom_color_count = 0
    custom_color_count = custom_pms_colors.split(',').count if custom_pms_colors
    standard_color_color + custom_color_count
  end

  def clear_log
    messages.clear
  end

  private

  def best_price(options = {})
    log("Best price called #{options}")
    # @see module Spree::QuoteCalculator
    best_price = calculate(options)

    return best_price if best_price.nil?

    # If we get here, we have rerun the price calculations
    # We have saved the database all of the shipping options
    # Let's refresh the cache here for all of them
    shipping_options.each do |shipping_option|
      unit_price_with_shipping = unit_price + (shipping_option.shipping_cost / quantity)
      Rails.cache.write(
        "#{cache_key(shipping_option.shipping_option)}/total_price",
        unit_price_with_shipping * quantity,
        expires_in: cache_expiration.hours
      )
    end
    best_price
  end

  def generate_reference
    update_column :reference, SecureRandom.hex(3).upcase
  rescue ActiveRecord::RecordNotUnique => e
    @reference_attempts ||= 0
    @reference_attempts += 1
    retry if @reference_attempts < 5
    raise e, 'Retries exhausted'
  end

  after_find do |quote|
    quote.messages = JSON.parse(quote.workbook).to_a unless quote.workbook.blank?
  end

  before_save do |quote|
    quote.messages.each { |m| Rails.logger.info(m) }
    quote.workbook = quote.messages.to_json
  end
end
