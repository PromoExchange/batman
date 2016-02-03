class Spree::CompanyStore < Spree::Base
  belongs_to :supplier, class_name: 'Spree::Supplier', inverse_of: :products
  belongs_to :buyer, class_name: 'Spree::User'

  validates :buyer_id, presence: true
  validates :supplier_id, presence: true
  validates :slug, presence: true
  validates :name, presence: true
end
