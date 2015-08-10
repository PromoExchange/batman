class Spree::UpchargeType < Spree::Base
  has_many :upcharges
  validates :name, presence: true
end
