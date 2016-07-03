FactoryGirl.define do
  factory :upcharge_type, class: Spree::UpchargeType do
    name 'pms_color_match'

    trait :run_charge do
      name 'run'
    end

    trait :setup_charge do
      name 'setup'
    end

    trait :additional_location_charge do
      name 'additional_location_run'
    end
  end
end
