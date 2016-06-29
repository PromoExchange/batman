FactoryGirl.define do
  factory :pms_color, class: 'Spree::PmsColor' do
    name 'PMS one'
    pantone 'pantone'
    hex '030323'
    custom false
    quote

    trait :custom do
      custom true
    end
  end
end
