FactoryGirl.define do
  factory :company_store, class: 'Spree::CompanyStore' do
    supplier
    association :buyer, factory: :px_user
    slug 'test'
    name 'CS Test'
    host 'test.promox.com'
    display_name 'The PX Company Store'
  end
end
