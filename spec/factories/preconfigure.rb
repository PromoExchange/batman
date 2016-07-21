FactoryGirl.define do
  factory :preconfigure, class: Spree::Preconfigure do
    product
    association :buyer, factory: :user
    imprint_method
    logo
    association :main_color, factory: :color_product
    custom_pms_colors '321'
  end
end
