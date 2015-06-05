FactoryGirl.define do
  factory :message, class: Spree::Message do
    association :owner, factory: :user
    association :from, factory: :user
    association :to, factory: :user
    status 'unread'
    body 'The quick brown jumped over the lazy dog.'
  end
end
