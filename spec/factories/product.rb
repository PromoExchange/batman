FactoryGirl.define do
  factory :px_product, class: Spree::Product, parent: :product do
    association :supplier, factory: :supplier_company_store
    association :original_supplier, factory: :supplier
    preconfigure
    price_code = '3V'

    after(:create) do |product|
      FactoryGirl.create_list(:color_product, 5, product: product)
      product.carton = FactoryGirl.create(:carton, product_id: product.id)
      product.imprint_methods << FactoryGirl.create(:imprint_method)
      company_store = FactoryGirl.create(:company_store, supplier: product.supplier)
      FactoryGirl.create(
        :markup,
        supplier_id: product.original_supplier_id,
        company_store_id: company_store.id
      )

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

    trait :with_no_eqp_range do
      no_eqp_range '(25..150)'
    end

    trait :with_price_codes do
      after(:create) do |product|
        Spree::VolumePrice.where(variant: product.master).update_all(price_code: 'PQR')
      end
    end

    trait :with_less_than_minimum do
      after(:create) do |product|
        create_list(
          :less_than_minimum_upcharge,
          1,
          related_id: product.id,
          imprint_method_id: product.imprint_method.id
        )
      end
    end

    trait :with_run_upcharges do
      after(:create) do |product|
        create_list(
          :product_run_upcharge,
          2,
          related_id: product.id,
          imprint_method_id: product.imprint_method.id
        )
      end
    end

    trait :with_setup_upcharges do
      after(:create) do |product|
        create_list(
          :product_setup_upcharge,
          1,
          related_id: product.id,
          imprint_method_id: product.imprint_method.id
        )
      end
    end

    trait :with_two_setup_upcharges do
      after(:create) do |product|
        create_list(
          :product_setup_upcharge,
          1,
          related_id: product.id,
          imprint_method_id: product.imprint_method.id,
          apply_count: 2
        )
      end
    end

    trait :with_range_setup_upcharges do
      after(:create) do |product|
        create(
          :product_setup_upcharge,
          range: '(1..1)',
          value: '50',
          related_id: product.id,
          imprint_method_id: product.imprint_method.id
        )
        create(
          :product_setup_upcharge,
          range: '2+',
          value: '100',
          related_id: product.id,
          imprint_method_id: product.imprint_method.id
        )
      end
    end

    trait :with_additional_location_upcharge do
      after(:create) do |product|
        create(
          :product_additional_location_upcharge,
          range: '(25..99)',
          value: '00.10',
          related_id: product.id,
          imprint_method_id: product.imprint_method.id
        )
        create(
          :product_additional_location_upcharge,
          range: '(100..199)',
          value: '00.08',
          related_id: product.id,
          imprint_method_id: product.imprint_method.id
        )
        create(
          :product_additional_location_upcharge,
          range: '200+',
          value: '00.05',
          related_id: product.id,
          imprint_method_id: product.imprint_method.id
        )
      end
    end

    trait :with_eqp do
      after(:create) do |product|
        product.markup.update_attributes(eqp_discount: 0.20, eqp: true)
      end
    end

    trait :with_fixed_price_per_item_carton do
      after(:create) do |product|
        Spree::Carton.destroy_all
        create(:carton, :with_fixed_price_per_item, product: product)
      end
    end

    trait :with_fixed_price_total_carton do
      after(:create) do |product|
        Spree::Carton.destroy_all
        create(:carton, :with_fixed_price_total, product: product)
      end
    end

    trait :with_carton do
      after(:create) do |product|
        Spree::Carton.destroy_all
        create(:carton, product: product)
      end
    end

    trait :with_upcharge_carton do
      after(:create) do |product|
        Spree::Carton.destroy_all
        create(:carton, :with_upcharge, product: product)
      end
    end
  end
end
