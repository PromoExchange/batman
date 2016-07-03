FactoryGirl.define do
  factory :upcharge, class: Spree::Upcharge do
    upcharge_type

    factory :supplier_upcharge, class: Spree::UpchargeSupplier do
      association :related, factory: :supplier
      value '55.00'
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
  end
end
