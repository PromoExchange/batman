FactoryGirl.define do
  factory :option_values_products, class: Spree::OptionValuesProduct do
    type 'Spree::Upcharge'
    association :option_value, factory: :option_value
    association :product, factory: :product
    value_type nil
    value nil

    factory :upcharge, class: Spree::Upcharge do
      value_type 'money'
      value '12.34'

      factory :upcharge_invalid_value_type do
        value_type 'ddd'
      end

      factory :upcharge_static_product do
        product_id 1
      end
    end
  end
end
