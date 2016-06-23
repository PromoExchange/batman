class Spree::ImprintMethod < Spree::Base
  has_and_belongs_to_many :products
  has_many :auctions
  has_many :quotes

  validates :name, presence: true
end
