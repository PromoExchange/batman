class Spree::Purchase
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :quantity,
    :product_id,
    :logo_id,
    :custom_pms_colors,
    :imprint_method_id,
    :main_color_id,
    :buyer_id,
    :price_breaks,
    :sizes,
    :ship_to_zip,
    :shipping_option

  validates :quantity, presence: true
  validates :product_id, presence: true
  validates :logo_id, presence: true
  validates :imprint_method_id, presence: true
  validates :main_color_id, presence: true
  validates :buyer_id, presence: true
  validates :price_breaks, presence: true
  validates :ship_to_zip, presence: true
  validates :shipping_option, presence: true

  def initialize(attributes = {})
    @errors = ActiveModel::Errors.new(self)
    attributes.each { |k, v| instance_variable_set("@#{k}", v) }
  end

  def persisted?
    false
  end

  def sizes
    %w(S M L XL 2XL)
  end
end
