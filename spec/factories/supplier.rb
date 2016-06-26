FactoryGirl.define do
  factory :supplier, class: Spree::Supplier do
    association :bill_address, factory: :address
    association :ship_address, factory: :address
    name Faker::Name.name
    company_store false

    factory :supplier_company_store, parent: :supplier do
      company_store true
    end
  end
end
