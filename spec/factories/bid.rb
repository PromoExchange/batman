require 'ffaker'
FactoryGirl.define do
  factory :bid, class: Spree::Bid do
    auction
    association :seller, factory: :user
    association :order, factory: :order
    association :prebid, factory: :prebid
    state 'open'

    trait :shipping do
      service_name 'Basic Shipping'
      shipping_cost 10.00
      delivery_days 6
    end
  end
end
