FactoryGirl.define do
  factory :review, class: Spree::Review do
    association :auction, factory: :auction
    association :user, factory: :user
    rating 3.3
    review 'This is a review'
    ip_address '192.168.2.2'
    approved true
  end
end
