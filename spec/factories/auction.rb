FactoryGirl.define do
  factory :auction, class: Spree::Auction do
    association :product, factory: :product
    association :buyer, factory: :px_user
    association :logo, factory: :logo
    quantity 1111
    started 5.days.ago
    ended nil
    association :imprint_method, factory: :imprint_method
    association :shipping_address, factory: :address
    association :main_color, factory: :color_product
    payment_method 'Credit Card'
    state 'open'
    shipping_agent 'ups'
    ship_to_zip 30308
    reference SecureRandom.hex(3)
    proof_file { File.new(Rails.root.join('spec', 'fixtures', 'batman.jpeg')) }
    association :customer, factory: :customer
  end

  # TODO: Convert to traits
  factory :auction_with_bids, parent: :auction do
    bids { build_list :bid, 10 }
  end

  factory :auction_with_one_bid, parent: :auction do
    bids { build_list :bid, 1 }
  end

  factory :waiting_confirmation, parent: :auction do
    state 'waiting_confirmation'
  end

  factory :delivered, parent: :auction do
    state 'delivered'
  end

  factory :no_ref_auction, parent: :auction do
    reference nil
  end

  factory :no_date_auction, parent: :auction do
    started nil
    ended nil
  end

  factory :cloned_factory, parent: :auction do
    association :clone, factory: :auction
  end
end
