FactoryGirl.define do
  factory :auction_payment, class: Spree::AuctionPayment do
    bid
    charge_id '1234'
    status 'pending'

    trait :failed do
      failure_code '123'
      failure_message 'Charge declined'
    end

    trait :requested do
      product_request
    end
  end
end
