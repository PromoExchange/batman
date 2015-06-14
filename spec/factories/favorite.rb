FactoryGirl.define do
  factory :favorite, class: Spree::Favorite do
    association :product, factory: :product
    association :buyer, factory: :user
  end
end
