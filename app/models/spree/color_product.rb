class Spree::ColorProduct < Spree::Base
  belongs_to :product
  validates :product_id, presence: true
  validates :color, presence: true
end
