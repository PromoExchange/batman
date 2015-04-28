# == Schema Information
#
# Table name: products
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  description  :string           not null
#  includes     :string
#  features     :string
#  packsize     :integer
#  packweight   :string
#  unit_measure :string
#  leadtime     :string
#  rushtime     :string
#  info         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  supplier_id  :integer          not null
#

FactoryGirl.define do
  factory :product do
    name 'name'
    description 'description'
    includes 'includes'
    features 'features'
    packsize 1
    packweight 'packweight'
    unit_measure 'unit_measure'
    leadtime 'leadtime'
    rushtime 'rushtime'
    info 'info'
    supplier_id 1
  end
end
