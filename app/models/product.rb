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
  # association. Wrong!
  #
  # The reason is that because the way supplier's view products
  #
  # Suppler A:
  #   Sells the BIC QuickFlick lighter
  # Supplier B:
  #   Also sells the BIC QuickFlick lighter
  #
  # Suppliers view them as seperate products and so we should also.
  # By doing that, we save a bunch of headaches with
  # the many other associations. We would have to
  # segment all associated products table by supplier_id.
  #
  # TL;DR. Products are not unique, product/suppliers are
  has_and_belongs_to_many :lines

  # Products can have many colors, colors are used by many products
  has_and_belongs_to_many :colors

  # Images *should* not be reused between products
  has_many :images

  # Products have many keywords, keywords are used by many products
  has_and_belongs_to_many :keywords

  has_one :supplier

  # Products can have many materials, materials are used by many products
  has_and_belongs_to_many :materials

  # Products can have many Media References, Media References are
  # used by many products
  # i.e. 2015 Q1 catalog, Page 23 can contain several products
  has_and_belongs_to_many :media_references

  # Products can have many Sizes, Sizes are used by many products
  # i.e. 2015 Q1 catalog, Page 23 can contain several products
  has_and_belongs_to_many :sizes

end
