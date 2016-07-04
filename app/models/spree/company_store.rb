class Spree::CompanyStore < Spree::Base
  belongs_to :supplier, class_name: 'Spree::Supplier', inverse_of: :products
  belongs_to :buyer, class_name: 'Spree::User'
  has_many :markups

  validates :buyer_id, presence: true
  validates :supplier_id, presence: true
  validates :slug, presence: true
  validates :name, presence: true

  def seller
    Spree::User.find_by(email: ENV['SELLER_EMAIL'])
  end
end
