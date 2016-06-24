FactoryGirl.define do
  factory :shipping_option, class: Spree::ShippingOption do
    quote
    name 'Ship Option 1'
    delta 1.0
    delivery_date Time.zone.now + 5.days
    delivery_days 5

    trait :ups_ground do
      shipping_option Spree::ShippingOption::OPTION[:ups_ground]
      shipping_cost 1.0
      total_price 10.0
    end

    trait :ups_3day_select do
      shipping_option Spree::ShippingOption::OPTION[:ups_3day_select]
      shipping_cost 3.0
      total_price 13.0
    end
  end
end