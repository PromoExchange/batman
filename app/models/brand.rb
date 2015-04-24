# == Schema Information
#
# Table name: brands
#
#  id         :integer          not null, primary key
#  brand      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Brand < ActiveRecord::Base
  validates :brand, presence: true
  has_many :lines
end
