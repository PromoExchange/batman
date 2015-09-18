require 'ffaker'
FactoryGirl.define do
  factory :bid, class: Spree::Bid do
    auction
    association :seller, factory: :user
    association :order, factory: :order
    association :prebid, factory: :prebid
    state 'open'
  end
end
