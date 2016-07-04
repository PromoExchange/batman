FactoryGirl.define do
  factory :carton, class: Spree::Carton do
    product
    width '10'
    length '11'
    height '12'
    weight '13'
    originating_zip '19020'
    quantity 150
    fixed_price nil
    per_item false

    trait :with_fixed_price_per_item do
      after(:build) do |carton|
        carton.fixed_price = 2.50
        carton.per_item = true
      end
    end

    trait :with_fixed_price_total do
      after(:build) do |carton|
        carton.fixed_price = 100.00
        carton.per_item = false
      end
    end
  end
end
