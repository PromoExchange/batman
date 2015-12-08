FactoryGirl.define do
  factory :logo, class: Spree::Logo do
    association :user, factory: :user
    logo_file { File.new(Rails.root.join('spec', 'fixtures', 'batman.psd')) }
  end
end
