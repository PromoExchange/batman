FactoryGirl.define do
  factory :option_values_products, class: Spree::OptionValuesProduct do
    type 'Spree::Upcharge'
    association :option_value, factory: :option_value
    association :product, factory: :product
    value_type nil
    value nil
  end
end
