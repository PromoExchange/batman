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
    :sizes

  validates :quantity, presence: true
  validates :product_id, presence: true
  validates :logo_id, presence: true
  validates :imprint_method_id, presence: true
  validates :main_color_id, presence: true
  validates :buyer_id, presence: true
  validates :price_breaks, presence: true

  def initialize
    @errors = ActiveModel::Errors.new(self)
  end

  def persisted?
    false
  end
end
