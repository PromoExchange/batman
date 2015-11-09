FactoryGirl.define do
  factory :pms_color, class: 'Spree::PmsColor' do
    name 'PMS one'
    pantone 'pantone'
    hex '030323'
  end
end
