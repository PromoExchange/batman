class Line < ActiveRecord::Base
  validates :name, presence: true
  validates :brand_id, presence: true
  belongs_to :brand
end
