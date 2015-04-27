# == Schema Information
#
# Table name: lines
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  brand_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :integer          not null
#

class Line < ActiveRecord::Base
  validates :name, presence: true
  validates :brand_id, presence: true
  belongs_to :brand
  belongs_to :product
end
