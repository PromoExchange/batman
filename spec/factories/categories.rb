# == Schema Information
#
# Table name: categories
#
#  id        :integer          not null, primary key
#  name      :string
#  parent_id :integer          not null
#

FactoryGirl.define do
  factory :category do
    name 'CATEGORY'
    parent_id 1
  end
end
