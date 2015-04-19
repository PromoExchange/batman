class Product::Category < ActiveRecord::Base
  validates :name, presence: true
end
