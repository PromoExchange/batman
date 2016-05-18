FactoryGirl.define do
  factory :carton, class: Spree::Carton do
    association :product, factory: :product
    width '10'
    length '11'
    height '12'
    weight '13'
    originating_zip '19020'
    quantity 150
    fixed_price nil
    per_item false
  end
end
