# == Schema Information
#
# Table name: category_related
#
#  id          :integer          not null, primary key
#  category_id :integer          not null
#  related_id  :integer          not null
#

# TODO: Not happy about this, check associations
FactoryGirl.define do
  factory :category_related do
    category_id 1
    related_id 1
    category
  end
end
