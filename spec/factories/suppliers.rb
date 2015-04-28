# == Schema Information
#
# Table name: suppliers
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :string
#

FactoryGirl.define do
  factory :supplier do
    name 'name'
    description 'description'
  end
end
