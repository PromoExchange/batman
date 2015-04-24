# == Schema Information
#
# Table name: keywords
#
#  id         :integer          not null, primary key
#  word       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :keyword do
    word "WORD"
  end
end
