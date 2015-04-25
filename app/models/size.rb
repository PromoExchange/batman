# == Schema Information
#
# Table name: sizes
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  width      :string
#  height     :string
#  depth      :string
#  dia        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Size < ActiveRecord::Base
  validates :name, presence: true
  # belongs_to :product
end
