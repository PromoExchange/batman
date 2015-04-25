# == Schema Information
#
# Table name: brands
#
#  id         :integer          not null, primary key
#  brand      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :brand do
    brand 'BRAND'
  end
end
