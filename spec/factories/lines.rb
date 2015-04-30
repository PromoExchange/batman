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
# Indexes
#
#  index_lines_on_brand_id  (brand_id)
#

FactoryGirl.define do
  factory :line do
    name 'LINENAME'
    brand
    products {[FactoryGirl.create(:product)]}
  end
end
