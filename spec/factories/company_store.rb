FactoryGirl.define do
  factory :company_store, class: 'Spree::CompanyStore' do
    association :supplier
    association :buyer, factory: :user
    slug 'test'
    name 'Company Store Test'
  end
end
