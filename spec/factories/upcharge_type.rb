FactoryGirl.define do
  factory :upcharge_type, class: Spree::UpchargeType do
    name 'pms_color_match'

    trait :less_than_minimum do
      name 'less_than_minimum'
    end

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
