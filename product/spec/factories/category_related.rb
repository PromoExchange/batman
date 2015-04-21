# TODO: Not happy about this, check associations
FactoryGirl.define do
  factory :category_related do
    category_id 1
    related_id 1
    category
  end
end
