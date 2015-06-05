FactoryGirl.define do
  factory :prebid, class: Spree::Prebid do
    taxon
    association :seller, factory: :user
    description 'This is a test'
  end
end
