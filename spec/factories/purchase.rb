FactoryGirl.define do
  factory :purchase, class: Spree::Purchase do
    quantity 200
    product_id 1
    logo_id 1
    custom_pms_colors '123'
    imprint_method_id 1
    main_color_id 1
    buyer_id 1
    price_breaks []
    sizes []
    ship_to_zip 11111
    after(:build) do |purchase|
      purchase.price_breaks << [100, 10.00]
      purchase.price_breaks << [200, 9.00]
    end

    trait :with_sizes do
      after(:build) do |purchase|
        purchase.sizes << %w(S M L XL)
      end
    end
  end
end
