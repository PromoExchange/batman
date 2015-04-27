# == Schema Information
#
# Table name: lines
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  brand_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Line < ActiveRecord::Base
  validates :name, presence: true
  validates :brand_id, presence: true
  belongs_to :brand
  # This may look odd
  # i.e. A Bic QuickFlick lighter is a commodity
  # so we should only have one brand/line/product
  # association.
  # But...
  # The reason is that a supplier's view of the products
  #
  # Suppler A:
  #   Sells the BIC QuickFlick lighter
  # Supplier B:
  #   Also sells the BIC QuickFlick lighter
  #
  # Supplier views them as seperate products so we do
  # By doing that, we save a bunch of headaches with
  # the many other assoications, we would have to
  # segment all products table by supplier_id
  #
  # TL;DR. Products are not unique, product/suppliers are
  has_and_belongs_to_many :products
end
