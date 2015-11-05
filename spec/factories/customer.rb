FactoryGirl.define do
  factory :customer, class: Spree::Customer do
    association :user, factory: :user
    token '1231232323'
    brand 'visa'
    last_4_digits '1234'
    payment_type 'cc'
    status 'verified'
  end
end
