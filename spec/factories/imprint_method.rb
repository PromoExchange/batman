FactoryGirl.define do
  factory :imprint_method, class: Spree::ImprintMethod do
    name Faker::Lorem.word
  end
end
