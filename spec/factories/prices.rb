# == Schema Information
#
# Table name: prices
#
#  id             :integer          not null, primary key
#  value_cents    :integer          default(0), not null
#  value_currency :string           default("USD"), not null
#  pricetype      :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  lower          :string
#  upper          :string
#  effective_date :datetime         default(Wed, 06 May 2015 18:44:16 UTC +00:00), not null
#  code           :string
#

FactoryGirl.define do
  factory :price do
    value_cents 0
    value_currency 'USD'
    pricetype 'base'
    effective_date '1/1/2015'
    code 'A'
    # products {[FactoryGirl.create(:product)]}
  end
end
