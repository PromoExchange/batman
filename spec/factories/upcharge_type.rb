FactoryGirl.define do
  factory :upcharge_type, class: Spree::UpchargeType do
    name 'pms_color_match'

    trait :run_charge do
      name 'run'
    end
  end
end
