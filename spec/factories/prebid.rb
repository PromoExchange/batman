FactoryGirl.define do
  factory :prebid, class: Spree::Prebid do
    association :seller, factory: :user
    supplier
    markup 0.1
    eqp false
    eqp_discount 0.1
  end
end
