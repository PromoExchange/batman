FactoryGirl.define do
  factory :imprint_method_product, class: Spree::ImprintMethodsProduct do
    association :imprint_method, factory: :imprint_method
    association :product, factory: :product
  end
end
