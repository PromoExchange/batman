# == Schema Information
#
# Table name: materials
#
#  id   :integer          not null, primary key
#  name :string           not null
#

FactoryGirl.define do
  factory :material do
    name 'material'
  end
end
