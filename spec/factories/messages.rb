FactoryGirl.define do
  factory :message, class: Spree::Message do
    owner_id 2
    from_id 1
    to_id 2
    status "unread"
    body "The quick brown jumped over the lazy dog."
  end
end
