FactoryGirl.define do
  factory :px_product, class: Spree::Product, parent: :product do
    carton
    association :supplier, factory: :supplier_company_store
    association :original_supplier, factory: :supplier

    after(:create) do |product|
      create_list(:color_product, 5, product: product)
      product.imprint_methods << FactoryGirl.create(:imprint_method)
      company_store = FactoryGirl.create(:company_store, supplier: product.original_supplier)
      create(:markup, supplier: product.original_supplier, company_store: company_store)
    end

    trait :with_upcharges do
      after(:create) do |product|
        create_list(:product_upcharge, 5, related_id: product.id)
      end
    end
  end
end
