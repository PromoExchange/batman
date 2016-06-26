FactoryGirl.define do
  factory :color_product, class: 'Spree::ColorProduct' do
    association :product, factory: :product
    color Faker::Lorem.word
  end
end
