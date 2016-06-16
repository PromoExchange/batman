namespace :companystore do
  desc 'Create Netmining Price Cache'
  task netmining_cache: :environment do
    company_store = Spree::CompanyStore.where(slug: 'netmining').first
    Spree::Product.where(supplier: company_store.supplier).each do |product|
      Spree::PriceCache.where(product: product).destroy_all
      product.refresh_price_cache
    end
  end

  desc 'Assign orginal Netmining suppliers'
  task netmining_original: :environment do
    [
      {
        query: { name: 'Ariel Premium Supply, Inc.', dc_acct_num: '100746' },
        skus: ['NM-EOS-LP15']
      },
      {
        query: { name: 'Brand Box' },
        skus: ['NM-1148WM']
      },
      {
        query: { dc_acct_num: '100383' },
        skus: ['NM-SM-6319']
      },
      {
        query: { dc_acct_num: '100257' },
        skus: ['NM-40061']
      },
      {
        query: { dc_acct_num: '100160' },
        skus: ['NM-354055']
      },
      {
        query: { name: 'Marmot' },
        skus: ['NM-98140']
      },
      {
        query: { name: 'American Apparel' },
        skus: ['NM-2001']
      }
    ].each do |supplier_data|
      supplier = Spree::Supplier.where(supplier_data[:query]).first_or_create
      raise "raiseed to find Supplier: #{supplier_data[:query]}" if supplier.blank?

      supplier_data[:skus].each do |product_sku|
        product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
        raise "raiseed to find product [#{product_sku}]" if product.nil?
        product.update_attributes(original_supplier: supplier)
      end
    end
  end

  desc 'Create Netmining company store'
  task netmining: :environment do
    user = Spree::User.where(email: 'amanda.witschger@netmining.com').first

    # User
    if user.nil?
      role = Spree::Role.where(name: 'buyer').first_or_create

      user = Spree::User.create(
        email: 'amanda.witschger@netmining.com',
        login: 'amanda.witschger@netmining.com',
        password: 'password123',
        password_confirmation: 'password123'
      )

      user.spree_roles << role
      user.generate_spree_api_key!

      country = Spree::Country.where(iso3: 'USA').first
      state = Spree::State.where(name: 'New York').first

      user.ship_address = Spree::Address.create(
        company: 'Netmining',
        firstname: 'Amanda',
        lastname: 'Witschger',
        address1: '200 Park Ave',
        address2: '27th Floor',
        city: 'New York',
        zipcode: '10166',
        state_id: state.id,
        country_id: country.id,
        phone: '6463605951'
      )

      user.bill_address = Spree::Address.create(
        company: 'Netmining',
        firstname: 'Amanda',
        lastname: 'Witschger',
        address1: '200 Park Ave',
        address2: '27th Floor',
        city: 'New York',
        zipcode: '10166',
        state_id: state.id,
        country_id: country.id,
        phone: '6463605951'
      )
      user.save!
      user.confirm!
    end

    # Add Logo
    if user.logos.where(custom: true).count == 0
      logo_file_name = File.join(Rails.root, 'db/company_store_data/netmining-logo.pdf')
      user.logos << Spree::Logo.create!(user: user, logo_file: open(logo_file_name), custom: true)
    end

    store_name = 'Netmining Company Store'

    # Supplier
    supplier = Spree::Supplier.where(name: store_name).first_or_create(
      billing_address: user.bill_address,
      shipping_address: user.ship_address,
      company_store: true
    )

    # Company Store
    Spree::CompanyStore.where(name: store_name).first_or_create(
      display_name: 'Netmining',
      slug: 'netmining',
      supplier: supplier,
      buyer: user
    )

    # Products
    ProductLoader.load('company_store', 'netmining')
    ProductLoader.load('company_store', 'netmining_upcharges')
    ProductLoader.load('company_store', 'netmining_preconfigure')

    Resque.enqueue(
      CompanyStorePrebid,
      name: store_name
    )
  end
end
