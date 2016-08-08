FactoryGirl.define do
  factory :quote, class: Spree::Quote do
    association :product, factory: :px_product
    quantity 25
    association :shipping_address, factory: :address
    association :main_color, factory: :color_product
    custom_pms_colors '116C, 115B'
    unit_price 0.0
    after(:create) do |quote|
      FactoryGirl.create_list(:shipping_option, 5, quote: quote)
      FactoryGirl.create_list(:pms_color, 2, quote: quote)
    end
    workbook ''
    selected_shipping_option Spree::ShippingOption::OPTION[:ups_ground]

    trait :with_less_than_minimum do
      association :product, factory: [:px_product, :with_less_than_minimum]
    end

    trait :with_setup_upcharges do
      association :product, factory: [:px_product, :with_setup_upcharges]
    end

    trait :with_run_upcharges do
      association :product, factory: [:px_product, :with_run_upcharges]
    end

    # TODO: Research better way to DRY these. Same with product factory
    # FIX: create([:quote,:with_run_upcharges,:with_setup_upcharges ])
    trait :with_setup_and_run_upcharges do
      association :product, factory: [
        :px_product,
        :with_setup_upcharges,
        :with_run_upcharges
      ]
    end

    trait :with_additional_location_upcharge do
      association :product, factory: [
        :px_product,
        :with_additional_location_upcharge
      ]
    end

    trait :with_fixed_price_per_item do
      association :product, factory: [
        :px_product,
        :with_fixed_price_per_item_carton
      ]
    end

    trait :with_fixed_price_total do
      association :product, factory: [
        :px_product,
        :with_fixed_price_total_carton
      ]
    end

    trait :with_carton do
      association :product, factory: [
        :px_product,
        :with_carton
      ]
    end
  end
end
