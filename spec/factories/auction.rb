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
    reference SecureRandom.hex(3)
  end

  factory :auction_with_bids, parent: :auction do
    bids { build_list :bid, 10 }
  end

  factory :auction_with_one_bid, parent: :auction do
    bids { build_list :bid, 1 }
  end

  factory :waiting_auction, parent: :auction do
    status 'waiting'
  end

  factory :no_ref_auction, parent: :auction do
    reference nil
  end

  factory :no_date_auction, parent: :auction do
    started nil
    ended nil
  end
end
