class Spree::ImprintMethodsProduct < Spree::Base
  belongs_to :imprint_method
  belongs_to :product

  validates :imprint_method_id, presence: true
  validates :product_id, presence: true

  delegate :name, to: :imprint_method
end
