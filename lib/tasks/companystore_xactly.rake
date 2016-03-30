namespace :companystore do
  desc 'Create Xactly Price Cache'
  task xactly_cache: :environment do
    company_store = Spree::CompanyStore.where(slug: 'xactly').first
    Spree::Product.where(supplier: company_store.supplier).each do |product|
      Spree::PriceCache.where(product: product).destroy_all
      product.refresh_price_cache
    end
  end

  desc 'Assign orginal xactly suppliers'
  task xactly_original: :environment do
    # Leeds
    leeds = Spree::Supplier.find_by(dc_acct_num: '100306')
    fail 'Failed to find leeds Supplier' if leeds.nil?

    leeds_sku = [
      'HT-8150-90'
    ]

    leeds_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      fail "Failed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: leeds)
    end

    # American Apparel
    american_apparel = Spree::Supplier.where(name: 'American Apparel').first_or_create
    fail 'Failed to find American Apparel Supplier' if american_apparel.nil?

    american_apparel_sku = [
      'HT-F497',
      'HT-TRT497',
      'HT-2001-WHITE',
      'HT-2001-GREY'
    ]

    american_apparel_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      fail "Failed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: american_apparel)
    end
  end

  desc 'Create Xactly company store'
  task xactly: :environment do
    user = Spree::User.where(email: 'mkuh@xactlycorp.com').first

    # User
    if user.nil?
      role = Spree::Role.where(name: 'buyer').first_or_create

      user = Spree::User.create(
        email: 'mkuh@xactlycorp.com',
        login: 'mkuh@xactlycorp.com',
        password: 'password123',
        password_confirmation: 'password123'
      )

      user.spree_roles << role
      user.generate_spree_api_key!

      country = Spree::Country.where(iso3: 'USA').first
      state = Spree::State.where(name: 'California').first

      user.ship_address = Spree::Address.create(
        company: 'Xactly',
        firstname: 'Marlene',
        lastname: 'Kuh',
        address1: '300 Park Ave #1700',
        city: 'San Jose',
        zipcode: '95110',
        state_id: state.id,
        country_id: country.id,
        phone: '8665587363'
      )

      user.bill_address = Spree::Address.create(
        company: 'Xactly',
        firstname: 'Marlene',
        lastname: 'Kuh',
        address1: '300 Park Ave #1700',
        city: 'San Jose',
        zipcode: '95110',
        state_id: state.id,
        country_id: country.id,
        phone: '8665587363'
      )
      user.save!
      user.confirm!
    end

    # Add Logo
    if user.logos.where(custom: true).count == 0
      logo_file_name = File.join(Rails.root, 'db/company_store_data/xactly-logo.pdf')
      user.logos << Spree::Logo.create!(user: user, logo_file: open(logo_file_name), custom: true)
    end

    store_name = 'Xactly Company Store'

    # Supplier
    supplier = Spree::Supplier.where(name: store_name).first
    if supplier.nil?
      supplier = Spree::Supplier.create(
        name: 'Xactly Company Store',
        billing_address: user.bill_address,
        shipping_address: user.ship_address,
        company_store: true
      )
      supplier.save!
    end

    # Company Store
    company_store_attr = {
      name: store_name,
      display_name: 'Xactly',
      slug: 'xactly',
      supplier: supplier,
      buyer: user
    }
    company_store = Spree::CompanyStore.where(name: store_name).first
    if company_store.nil?
      company_store = Spree::CompanyStore.create(company_store_attr)
    end
    company_store.update_attributes(company_store_attr)
    company_store.save!

    # Products
    # ProductLoader.load('company_store', 'xactly')
    # ProductLoader.load('company_store', 'xactly_upcharges')
    # ProductLoader.load('company_store', 'xactly_preconfigure')

    # Resque.enqueue(
    #   CompanyStorePrebid,
    #   name: store_name
    # )
  end
end
