FactoryGirl.define do
  factory :quote, class: Spree::Quote do
    association :product, factory: [:px_product, :with_setup_upcharges]
    quantity 1111
    association :shipping_address, factory: :address
    association :main_color, factory: :color_product
    custom_pms_colors '116C, 115B'
    unit_price 0.0
    after(:create) do |quote|
      create_list(:shipping_option, 5, :ups_ground, quote: quote)
      create_list(:pms_color, 2, quote: quote)
    end
    workbook ''
    selected_shipping_option Spree::ShippingOption::OPTION[:ups_ground]
  end
end
