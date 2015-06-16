FactoryGirl.define do
  factory :upcharge, class: Spree::Upcharge do
    upcharge_type_id 1

    factory :supplier_upcharge, class: Spree::Upcharge do
      related_type 'Spree::Supplier'
      association :related, factory: :supplier
      value '55.00'
    end

    factory :product_upcharge, class: Spree::Upcharge do
      related_type 'Spree::Product'
      association :related, factory: :product
      value '0.23'
    end
  end
end
