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

FactoryGirl.define do
  factory :size do
    name 'name'
    width 'width'
    height 'height'
    depth 'depth'
    dia 'dia'
  end
end
