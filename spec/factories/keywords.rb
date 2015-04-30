# == Schema Information
#
# Table name: keywords
#
#  id   :integer          not null, primary key
#  word :string           not null
#

FactoryGirl.define do
  factory :keyword do
    word 'WORD'
    products {[FactoryGirl.create(:product)]}
  end
end
