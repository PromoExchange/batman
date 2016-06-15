FactoryGirl.define do
  factory :quote, class: Spree::Quote do
    association :product
    quantity 1111
    association :imprint_method
    association :shipping_address, factory: :address
    association :main_color, factory: :color_product
    custom_pms_colors '116C'
  end
end
