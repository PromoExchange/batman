FactoryGirl.define do
  factory :carton, class: Spree::Carton do
    association :product, factory: :product
    width '10'
    length '11'
    height '12'
    weight '13'
    originating_zip '11111'
    quantity 150
  end
end