class Spree::Supplier < Spree::Base
  has_many :products, class_name: 'Spree::Product', inverse_of: :supplier
  has_and_belongs_to_many :pms_colors
  has_many :upcharges, as: :related
  has_many :pms_colors_supplier

  belongs_to :bill_address, foreign_key: :billing_address_id, class_name: 'Spree::Address'
  alias_attribute :billing_address, :bill_address

  belongs_to :ship_address, foreign_key: :shipping_address_id, class_name: 'Spree::Address'
  alias_attribute :shipping_address, :ship_address

  validates :name, presence: true
end
