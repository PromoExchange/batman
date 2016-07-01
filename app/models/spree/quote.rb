class Spree::Quote < Spree::Base
  include QuoteCalculator

  after_create :generate_reference

  belongs_to :main_color, class_name: 'Spree::ColorProduct'
  belongs_to :shipping_address, class_name: 'Spree::Address'
  belongs_to :imprint_method
  has_many :shipping_options, dependent: :destroy
  has_many :pms_colors

  # Assumes products are not shared across company stores
  belongs_to :product

  attr_writer :messages
  attr_writer :cache_expiration
  attr_writer :write_log

  def messages
    @messages ||= []
  end

  def cache_expiration
    @cache_expiration || 12
  end

  def write_log
    @write_log || true
  end

  validates :main_color, presence: true
  validates :product, presence: true
  validates :selected_shipping_option, presence: true
  validates :shipping_address, presence: true
  validates :imprint_method, presence: true
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: (lambda do |quote|
      50 if quote.product.nil?
      quote.product.minimum_quantity
    end)
  }

  delegate :company_store, to: :product
  delegate :markup, to: :product

  def total_price(options = {})
    options.reverse_merge!(
      selected_shipping_option: Spree::ShippingOption::OPTION[:ups_ground]
    )
    Rails.cache.fetch("#{cache_key}/total_price", expires_in: cache_expiration.hours) do
      best_price(options)
    end
  end

  def cache_key
    "spree/quote/#{product.id}/#{quantity}/#{selected_shipping_option}"
  end

  def log(message)
    messages << message if write_log == true
  end

  def num_colors
    standard_color_color = pms_colors.count
    custom_color_count = custom_pms_colors.split(',').count
    standard_color_color + custom_color_count
  end

  private

  def best_price(options = {})
    # @see module Spree::QuoteCalculator
    calculate(options)
  end

  def generate_reference
    update_column :reference, SecureRandom.hex(3).upcase
  rescue ActiveRecord::RecordNotUnique => e
    @reference_attempts ||= 0
    @reference_attempts += 1
    retry if @reference_attempts < 5
    raise e, 'Retries exhausted'
  end

  after_find do |_quote|
    self.messages = JSON.parse(workbook).to_a unless workbook.blank?
  end

  before_save do |_quote|
    self.workbook = messages.to_json
  end
end
