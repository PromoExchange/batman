# == Schema Information
#
# Table name: sizes
#
#  id     :integer          not null, primary key
#  name   :string           not null
#  width  :string
#  height :string
#  depth  :string
#  dia    :string
#

FactoryGirl.define do
  factory :size do
    name 'name'
    width 'width'
    height 'height'
    depth 'depth'
    dia 'dia'
    # products {[FactoryGirl.create(:product)]}
  end
end
