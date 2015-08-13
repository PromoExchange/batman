FactoryGirl.define do
  factory :prebid, class: Spree::Prebid do
    association :seller, factory: :user
    product
  end
end
