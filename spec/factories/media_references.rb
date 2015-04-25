# == Schema Information
#
# Table name: media_references
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  location   :string           not null
#  reference  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :media_reference do
    name 'name'
    location 'catalog'
    reference '347'
  end
end
