FactoryGirl.define do
  factory :supplier, class: Spree::Supplier do
    address
    name Faker::Name.name
    description Faker::Lorem.sentence(5)
  end
end
