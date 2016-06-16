require 'faker'

FactoryGirl.define do
  factory :address, class: Spree::Address do
    firstname Faker::Name.first_name
    lastname Faker::Name.last_name
    address1 Faker::Address.street_address
    city Faker::Address.city
    state Spree::State.find_by name: Faker::Address.state
    zipcode Faker::Address.zip
    country Spree::Country.find_by iso: 'US'
    phone Faker::PhoneNumber.phone_number
    company Faker::Company.name
  end

  factory :address_with_address2, parent: :address do
    address2 Faker::Address.secondary_address
  end
end
