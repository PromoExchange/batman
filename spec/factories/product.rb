FactoryGirl.define do
  factory :px_product, class: Spree::Product, parent: :product do
    carton
    association :supplier, factory: :supplier_company_store
    association :original_supplier, factory: :supplier

    after(:create) do |product|
      create_list(:color_product, 5, product: product)
      product.imprint_methods << FactoryGirl.create(:imprint_method)
      company_store = FactoryGirl.create(:company_store, supplier: product.supplier)
      create(:markup, supplier_id: product.original_supplier_id, company_store_id: company_store.id)

      price_code = '3V'
      i = 0
      [
        ['(25..99)', 29.99],
        ['(100..199)', 27.99],
        ['200+', 25.99]
      ].each do |volume_price|
        price = volume_price[1]
        range = volume_price[0]
        Spree::VolumePrice.where(
          variant: product.master,
          name: range,
          range: range,
          amount: price,
          position: i + 1,
          discount_type: 'price',
          price_code: price_code
        ).first_or_create
        i += 1
      end
    end

    trait :with_upcharges do
      after(:create) do |product|
        create_list(:product_upcharge, 5, related_id: product.id)
      end
    end

    trait :with_eqp do
      after(:create) do |product|
        product.markup.update_attributes(eqp_discount: 0.20)
      end
    end
  end
end
