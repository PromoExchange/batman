require 'ffaker'
FactoryGirl.define do
  factory :auction, class: Spree::Auction do
    association :product, factory: :product
    association :buyer, factory: :user
    quantity 1111
    started 5.days.ago
    ended nil
    association :imprint_method, factory: :imprint_method
    association :shipping_address, factory: :address
    association :main_color, factory: :color_product
    payment_method 'Credit Card'
    status 'open'
  end

  factory :auction_with_bids, parent: :auction do
    bids { build_list :bid, 10 }
  end
end
