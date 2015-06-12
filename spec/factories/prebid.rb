FactoryGirl.define do
  factory :prebid, class: Spree::Prebid do
    association :seller, factory: :user
    product
    description 'This is a test'
  end
end
