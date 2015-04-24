# == Schema Information
#
# Table name: materials
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :material do
    name 'material'
  end
end
