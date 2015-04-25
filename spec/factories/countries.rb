# == Schema Information
#
# Table name: countries
#
#  id           :integer          not null, primary key
#  code_2       :string           not null
#  code_3       :string           not null
#  short_name   :string           not null
#  code_numeric :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :country do
    code_2 'XX'
    code_3 'XXX'
    code_numeric 123
    short_name 'Short description'
  end
end
