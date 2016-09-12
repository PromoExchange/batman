class Spree::ColorProduct < Spree::Base
  belongs_to :product
  has_many :purchases

  validates :product, presence: true
  validates :color, presence: true
end
