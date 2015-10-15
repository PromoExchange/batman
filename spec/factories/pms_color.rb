FactoryGirl.define do
  factory :pms_color, class: 'Spree::PmsColor' do
    name 'PMS one'
    pantone 'PANTONE C113'
    hex '030323'
  end
end
