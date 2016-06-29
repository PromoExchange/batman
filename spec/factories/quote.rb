FactoryGirl.define do
  factory :quote, class: Spree::Quote do
    association :product, factory: :px_product
    quantity 1111
    imprint_method
    association :shipping_address, factory: :address
    association :main_color, factory: :color_product
    custom_pms_colors '116C, 115B'
    unit_price 0.0
    # reference SecureRandom.hex(3)
    after(:create) do |quote|
      create_list(:shipping_option, 5, :ups_ground, quote: quote)
    end
    workbook ''
  end
end
