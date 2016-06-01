FactoryGirl.define do
  factory :shipping_option, class: Spree::ShippingOption do
    bid
    name 'Ship Option 1'
    delta 1.0
  end
end
