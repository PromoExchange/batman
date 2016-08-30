FactoryGirl.define do
  factory :shipping_option, class: Spree::ShippingOption do
    quote
    name 'Ship Option 1'
    delivery_date Time.zone.now + 5.days
    delivery_days 5
    shipping_option Spree::ShippingOption::OPTION[:ups_ground]
    shipping_cost 1.0

    trait :ups_3day_select do
      shipping_option Spree::ShippingOption::OPTION[:ups_3day_select]
      shipping_cost 3.0
    end

    trait :fixed_price_per_item do
      shipping_option Spree::ShippingOption::OPTION[:fixed_price_per_item]
      shipping_cost 4.0
    end
  end
end
