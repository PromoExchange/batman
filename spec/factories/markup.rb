FactoryGirl.define do
  factory :markup, class: Spree::Markup do
    supplier
    markup 0.1
    eqp false
    eqp_markup 0.0
  end
end
