FactoryGirl.define do
  factory :px_user, parent: :user do
    association :ship_address, factory: :address
  end

  trait :with_tax_rates do
    after(:create) do |px_user|
      create(
        :tax_rate,
        user_id: px_user.id,
        amount: 0.1
      )
    end
  end
end
