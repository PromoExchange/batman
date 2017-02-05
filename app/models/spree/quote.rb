class Spree::Quote < Spree::Base
  include QuoteCalculator

  enum shipping_option: [
    :ups_ground,
    :ups_3day_select,
    :ups_second_day_air,
    :ups_next_day_air_saver,
    :ups_next_day_air,
    :ups_next_day_air_early_am,
    :fixed_price_per_item,
    :fixed_price_total
  ]

  # TODO: remove reference, move to purchase
  after_create :generate_reference

  belongs_to :main_color, class_name: 'Spree::ColorProduct'

  # TODO: Remove, delegate to buyer (via CS)
  belongs_to :shipping_address, class_name: 'Spree::Address'
  has_many :pms_colors

  # TODO: Fix association between quote and product
  # Assumes products are not shared across company stores
  belongs_to :product

  delegate :fixed_price_shipping?, to: :product

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

  def shipping_option_name
    return 'Fixed Price' if fixed_price_shipping?
    shipping_option.to_s.titleize.sub('Ups', 'UPS')
  end

  validates :main_color, presence: true
  validates :product, presence: true
  validates :shipping_option, presence: true
  validates :shipping_address, presence: true
  validates_associated :product
  validates_associated :main_color
  validates_associated :shipping_address
  validates_associated :pms_colors

  delegate :company_store, to: :product
  delegate :markup, to: :product
  delegate :imprint_method, to: :product

  def clear_cache
    return if cache_keys.nil?
    cache_keys.each do |k|
      Rails.cache.delete(k)
    end
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

  def price
    Rails.cache.fetch("#{cache_key}/price", expires_in: cache_expiration.hours) do
      best_price
      {
        total_price: unit_price * quantity,
        unit_price: unit_price,
        shipping_cost: shipping_cost,
        shipping_days: shipping_days
      }
    end
  end

  def generate_reference
    update_column :reference, SecureRandom.hex(3).upcase
  rescue ActiveRecord::RecordNotUnique => e
    @reference_attempts ||= 0
    @reference_attempts += 1
    retry if @reference_attempts < 5
    raise e, 'Retries exhausted'
  end

  # TODO: http://api.rubyonrails.org/classes/ActiveRecord/Store.html
  after_find do |quote|
    quote.messages = JSON.parse(quote.workbook).to_a unless quote.workbook.blank?
  end

  before_save do |quote|
    quote.messages.each { |m| Rails.logger.info(m) }
    quote.workbook = quote.messages.to_json
  end

  def cache_keys
    cache_data = Rails.cache.instance_variable_get('@data')
    cache_data.keys.select { |k, _v| k.start_with?(cache_key) } unless cache_data.nil?
  end

  def cache_key
    "#{model_name.cache_key}/#{id || 'new'}"
  end

  def log(message)
    messages << message if write_log == true
  end
end
