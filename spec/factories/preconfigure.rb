FactoryGirl.define do
  factory :preconfigure, class: Spree::Preconfigure do
    association :product, factory: :product
    association :buyer, factory: :user
    association :imprint_method, factory: :imprint_method
    association :logo, factory: :logo
    association :main_color, factory: :color_product
    custom_pms_colors '321'
  end
end
