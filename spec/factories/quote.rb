FactoryGirl.define do
  factory :quote, class: Spree::Quote do
    product
    quantity 1111
    imprint_method
    association :shipping_address, factory: :address
    association :main_color, factory: :color_product
    custom_pms_colors '116C'

    trait :with_shipping_options do
      after(:create) do |quote|
        create_list(:shipping_option, 5, :ups_ground, quote: quote)
      end
    end

    trait :with_workbook do
      workbook Faker::Lorem.paragraphs(10)
    end
  end
end
