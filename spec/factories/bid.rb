require 'ffaker'
FactoryGirl.define do
  factory :bid, class: Spree::Bid do
    auction
    association :seller, factory: :user
    association :order, factory: :order
    description Faker::Lorem.sentence(5)
  end
end
