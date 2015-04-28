# == Schema Information
#
# Table name: products
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  description  :string           not null
#  includes     :string
#  features     :string
#  packsize     :integer
#  packweight   :string
#  unit_measure :string
#  leadtime     :string
#  rushtime     :string
#  info         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  supplier_id  :integer          not null
#

class Product < ActiveRecord::Base
  validates :name, presence: true
  validates :supplier_id, presence: true
  validates :description, presence: true

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
  # Suppliers view them as seperate products so we do.
  # By doing that, we save a bunch of headaches with
  # the many other associations, we would have to
  # segment all products table by supplier_id
  #
  # TL;DR. Products are not unique, product/suppliers are
  has_and_belongs_to_many :lines
end
