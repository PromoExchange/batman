FactoryGirl.define do
  factory :shipping_option, class: Spree::ShippingOption do
    bid
    name 'Ship Option 1'
    delta 1.0
    delivery_date Time.zone.now + 5.days
    delivery_days 5
    shipping_option 1
  end
end
