FactoryGirl.define do
  factory :quote, class: Spree::Quote do
    association :product, factory: :px_product
    quantity 25
    shipping_days 5
    shipping_cost 100.0
    association :shipping_address, factory: :address
    association :main_color, factory: :color_product
    custom_pms_colors '116C, 115B'
    unit_price 0.0
    after(:create) do |quote|
      FactoryGirl.create_list(:pms_color, 2, quote: quote)
    end
    workbook ''
    shipping_option :ups_ground

    trait :with_less_than_minimum do
      association :product, factory: [:px_product, :with_less_than_minimum]
    end

    trait :with_setup_upcharges do
      association :product, factory: [:px_product, :with_setup_upcharges]
    end

    trait :with_two_setup_upcharges do
      association :product, factory: [:px_product, :with_two_setup_upcharges]
    end

    trait :with_range_setup_upcharges do
      association :product, factory: [:px_product, :with_range_setup_upcharges]
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
      shipping_option :fixed_price_per_item
    end

    trait :with_fixed_price_total do
      association :product, factory: [
        :px_product,
        :with_fixed_price_total_carton
      ]
      shipping_option :fixed_price_total
    end

    trait :with_carton do
      association :product, factory: [
        :px_product,
        :with_carton
      ]
    end

    trait :with_carton_upcharge do
      association :product, factory: [
        :px_product,
        :with_upcharge_carton
      ]
    end

    # Shipping Traits
    trait :with_3day_select do
      shipping_option :ups_3day_select
      shipping_days 3
    end
  end
end
