class Product::Detail < ActiveRecord::Base
  validates :name, presence: true
  validates :price, presence: true
end
