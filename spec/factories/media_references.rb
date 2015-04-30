# == Schema Information
#
# Table name: media_references
#
#  id        :integer          not null, primary key
#  name      :string           not null
#  location  :string           not null
#  reference :string           not null
#

FactoryGirl.define do
  factory :media_reference do
    name 'name'
    location 'catalog'
    reference '347'
    products {[FactoryGirl.create(:product)]}
  end
end
