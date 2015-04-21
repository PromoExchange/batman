class Brand < ActiveRecord::Base
  validates :brand, presence: true
  has_many :lines
end
