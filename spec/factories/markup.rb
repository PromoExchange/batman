FactoryGirl.define do
  factory :markup, class: Spree::Markup do
    supplier
    markup 0.1
    live true
    eqp_discount 0.0
    company_store
    eqp false
  end

  trait :eqp_discount do
    eqp_discount 0.2
  end

  trait :with_eqp do
    eqp true
  end
end
