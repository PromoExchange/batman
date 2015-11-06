class Spree::PmsColor < Spree::Base
  has_and_belongs_to_many :suppliers
  validates :name, presence: true
end
