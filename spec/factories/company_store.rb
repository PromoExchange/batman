FactoryGirl.define do
  factory :company_store, class: 'Spree::CompanyStore' do
    supplier
    association :buyer, factory: :user
    logo { File.new(Rails.root.join('spec', 'fixtures', 'batman.jpeg')) }
    slug 'test'
    name 'CS Test'
    host 'test.promox.com'
    display_name 'The PX Company Store'
  end
end
