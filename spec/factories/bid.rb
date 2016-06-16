FactoryGirl.define do
  factory :bid, class: Spree::Bid do
    auction
    association :seller, factory: :user
    association :order
    association :prebid
    state 'open'

    trait :shipping do
      service_name 'Basic Shipping'
      shipping_cost 10.00
      delivery_days 6
    end

    trait :with_shipping_options do
      after(:create) do |bid|
        create_list(:shipping_option, 5, :ups_ground, bid: bid)
      end
    end
  end
end
