class Spree::OptionValuesProduct < Spree::Base
  belongs_to :product
  belongs_to :option_value

  validates :product_id, presence: true
  validates :option_value_id, presence: true
end
