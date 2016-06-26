FactoryGirl.define do
  factory :upcharge, class: Spree::Upcharge do
    upcharge_type

    factory :supplier_upcharge, class: Spree::UpchargeSupplier do
      association :related, factory: :supplier
      value '55.00'
    end

    factory :product_upcharge, class: Spree::UpchargeProduct do
      association :related, factory: :product
      association :upcharge_type, factory: [:upcharge_type, :run_charge]
      value '0.23'
    end
  end
end
