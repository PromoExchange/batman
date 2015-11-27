FactoryGirl.define do
  factory :supplier, class: Spree::Supplier do
    association :bill_address, factory: :address
    association :ship_address, factory: :address
    name Faker::Name.name
  end
end
