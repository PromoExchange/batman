# == Schema Information
#
# Table name: brands
#
#  id   :integer          not null, primary key
#  name :string           not null
#

FactoryGirl.define do
  factory :brand do
    name 'BRAND'
  end
end
