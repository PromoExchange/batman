FactoryGirl.define do
  factory :supplier, class: Spree::Prebid do
    address
    name Faker::Name.name
    description Faker::Lorem.sentence(5)
  end
end
