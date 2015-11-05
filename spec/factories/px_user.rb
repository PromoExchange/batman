FactoryGirl.define do
  factory :px_user, parent: :user do
    customers { build_list :customer, 1 }
  end
end
