# == Schema Information
#
# Table name: category_related
#
#  id          :integer          not null, primary key
#  category_id :integer          not null
#  parent_id   :integer          not null
#
# Indexes
#
#  index_category_related_on_category_id  (category_id)
#  index_category_related_on_parent_id    (parent_id)
#

# TODO: Not happy about this, check associations
FactoryGirl.define do
  factory :category_related do
    category_id 1
    related_id 1
    category
  end
end
