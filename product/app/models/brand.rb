class Brand < ActiveRecord::Base
  validates :brand, presence: true
end
