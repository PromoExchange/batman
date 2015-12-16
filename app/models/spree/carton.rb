class Spree::Carton < Spree::Base
  belongs_to :product
  validates :product_id, presence: true
end
