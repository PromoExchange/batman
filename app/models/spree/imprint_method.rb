class Spree::ImprintMethod < Spree::Base
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  has_and_belongs_to_many :products

  validates :name, presence: true
end
