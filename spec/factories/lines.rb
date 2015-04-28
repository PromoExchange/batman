# == Schema Information
#
# Table name: lines
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  brand_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryGirl.define do
  factory :line do
    name 'LINENAME'
    brand
  end
end
