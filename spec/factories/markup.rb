FactoryGirl.define do
  factory :markup, class: Spree::Markup do
    supplier
    markup 0.1
    eqp false
    eqp_discount 0.0
    company_store
  end
end
