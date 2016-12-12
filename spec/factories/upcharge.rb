FactoryGirl.define do
  factory :upcharge, class: Spree::Upcharge do
    upcharge_type

    factory :supplier_upcharge, class: Spree::UpchargeSupplier do
      association :supplier, factory: :supplier
      value '55.00'
    end

    # TODO: DRY These
    factory :less_than_minimum_upcharge, class: Spree::UpchargeProduct do
      association :related, factory: :product
      association :upcharge_type, factory: [:upcharge_type, :less_than_minimum]
      value '60.00'
      price_code 'K'
      range '(1..50)'
    end

    factory :product_run_upcharge, class: Spree::UpchargeProduct do
      association :related, factory: :product
      association :upcharge_type, factory: [:upcharge_type, :run_charge]
      value '0.23'
      price_code 'V'
      range '1+'
    end

    factory :product_setup_upcharge, class: Spree::UpchargeProduct do
      association :related, factory: :product
      association :upcharge_type, factory: [:upcharge_type, :setup_charge]
      value '50.00'
      price_code 'K'
      range '1+'
    end

    factory :product_additional_location_upcharge, class: Spree::UpchargeProduct do
      association :related, factory: :product
      association :upcharge_type, factory: [:upcharge_type, :additional_location_charge]
      value '00.10'
      price_code 'V'
      range '1+'
    end
  end
end
