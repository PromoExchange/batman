class Material < ActiveRecord::Base
  validates :material, presence: true
  # belongs_to :product
end
