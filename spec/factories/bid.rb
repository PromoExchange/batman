require 'ffaker'
FactoryGirl.define do
  factory :bid, class: Spree::Bid do
    auction
    association :seller, factory: :user
    description Faker::Lorem.sentence(5)
    bid 2222.33
  end
end
