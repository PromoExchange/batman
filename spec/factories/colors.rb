# == Schema Information
#
# Table name: colors
#
#  id   :integer          not null, primary key
#  name :string           not null
#

FactoryGirl.define do
  factory :color do
    name 'name'
    products {[FactoryGirl.create(:product)]}
  end
end
