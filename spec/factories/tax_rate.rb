FactoryGirl.define do
  factory :px_tax_rate, parent: :tax_rate do
    association :user, factory: :px_user
    include_in_sandh false
  end
end
