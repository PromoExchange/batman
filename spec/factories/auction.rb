require 'ffaker'
FactoryGirl.define do
  factory :auction, class: Spree::Auction do
    association :product, factory: :product
    association :buyer, factory: :user
    quantity 1111# {Faker::Number.number(4)}
    description {Faker::Lorem.sentence(5)}
    started 5.days.ago
    ended nil
  end

  factory :auction_with_bids, parent: :auction do |auction|
    bids{ build_list :bid, 10}
  end
end
