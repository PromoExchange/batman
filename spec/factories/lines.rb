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

# TODO: Again, fix the associations
FactoryGirl.define do
  factory :line do
    name 'LINENAME'
    brand_id 1
  end
end
