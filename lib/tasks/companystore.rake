
namespace :companystore do
  desc 'Create Anchorfree Price Cache'
  task anchorfree_cache: :environment do
    company_store = Spree::CompanyStore.where(slug: 'anchorfree').first
    Spree::Product.where(supplier: company_store.supplier).each do |product|
      Spree::PriceCache.where(product: product).destroy_all
      product.refresh_price_cache
    end
  end

  desc 'Assign original suppliers'
  task anchorfree_original: :environment do
    # Sanmar Products
    sanmar = Spree::Supplier.find_by(dc_acct_num: '100160')
    fail 'Failed to find Sanmar Supplier' if sanmar.nil?

    sanmar_skus = [
      'AF-632418',
      'AF-5170',
      'AF-71600'
    ]

    sanmar_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      fail "Failed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: sanmar)
    end

    # Bullet Products
    bullet = Spree::Supplier.find_by(dc_acct_num: '100383')
    fail 'Failed to find Bullet Supplier' if bullet.nil?

    bullet_skus = [
      'AF-SM-4125',
      'AF-SM-2381'
    ]

    bullet_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      fail "Failed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: bullet)
    end

    # Leeds Products
    leeds = Spree::Supplier.find_by(dc_acct_num: '100306')
    fail 'Failed to find Leeds Supplier' if leeds.nil?

    leeds_skus = [
      'AF-7003-40',
      'AF-3250-99',
      'AF-2050-02'
    ]

    leeds_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      fail "Failed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: leeds)
    end

    # Gemline Products
    gemline = Spree::Supplier.find_by(dc_acct_num: '100306')
    fail 'Failed to find Gemline Supplier' if gemline.nil?

    gemline_skus = [
      'AF-MOLEHRD'
    ]

    gemline_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      fail "Failed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: gemline)
    end

    # BIC Graphic Products
    bic_graphic = Spree::Supplier.where(
      name: 'BIC Graphic',
      dc_acct_num: '100104'
    ).first_or_create
    fail 'Failed to find BIC Graphic Supplier' if bic_graphic.nil?

    bic_graphic_skus = [
      'AF-P3A3A25'
    ]

    bic_graphic_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      fail "Failed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: bic_graphic)
    end

    # Innovation Line Products
    innovation_line = Spree::Supplier.where(
      name: 'Innovation Line',
      dc_acct_num: '100108'
    ).first_or_create
    fail 'Failed to find Innovation Line Supplier' if innovation_line.nil?

    innovation_line_skus = [
      'AF-5117'
    ]

    innovation_line_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      fail "Failed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: innovation_line)
    end

    # Jetline Products
    jetline = Spree::Supplier.where(
      name: 'Jetline',
      dc_acct_num: '120402'
    ).first_or_create
    fail 'Failed to find Jetline Supplier' if jetline.nil?

    jetline_skus = [
      'AF-SG120'
    ]

    jetline_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      fail "Failed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: jetline)
    end

    # Quaker City Caps Products
    quakercity = Spree::Supplier.where(
      name: 'Quaker City Caps'
    ).first_or_create
    fail 'Failed to find Quaker City Caps Supplier' if quakercity.nil?

    quakercity_skus = [
      'AF-8500'
    ]

    quakercity_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      fail "Failed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: quakercity)
    end
  end

  desc 'Create anchor free company store'
  task anchorfree: :environment do
    user = Spree::User.where(email: 'dwittig@anchorfree.com').first

    # User
    if user.nil?
      role = Spree::Role.where(name: 'buyer').first_or_create

      user = Spree::User.create(
        email: 'dwittig@anchorfree.com',
        login: 'dwittig@anchorfree.com',
        password: 'spree123',
        password_confirmation: 'spree123'
      )

      user.spree_roles << role
      user.generate_spree_api_key!

      country = Spree::Country.where(iso3: 'USA').first
      state = Spree::State.where(name: 'California').first

      user.ship_address = Spree::Address.create(
        company: 'AnchorFree',
        firstname: 'Drew',
        lastname: 'Wittig',
        address1: '155 Constitution Drive',
        city: 'Menlo Park',
        zipcode: '94025',
        state_id: state.id,
        country_id: country.id,
        phone: '4087441002'
      )

      user.bill_address = Spree::Address.create(
        company: 'AnchorFree',
        firstname: 'Drew',
        lastname: 'Wittig',
        address1: '155 Constitution Drive',
        city: 'Menlo Park',
        zipcode: '94025',
        state_id: state.id,
        country_id: country.id,
        phone: '4087441002'
      )
      user.save!
      user.confirm!
    end

    # Add Logo
    if user.logos.where(custom: true).count == 0
      logo_file_name = File.join(Rails.root, 'db/company_store_data/anchorfree-logo.pdf')
      user.logos << Spree::Logo.create!(user: user, logo_file: open(logo_file_name), custom: true)
    end

    store_name = 'AnchorFree Company Store'

    # Supplier
    supplier = Spree::Supplier.where(name: store_name).first
    if supplier.nil?
      supplier = Spree::Supplier.create(
        name: 'AnchorFree Company Store',
        billing_address: user.bill_address,
        shipping_address: user.ship_address,
        company_store: true
      )
      supplier.save!
    end

    # Company Store
    company_store_attr = {
      name: store_name,
      display_name: 'AnchorFree',
      slug: 'anchorfree',
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
    ProductLoader.load('company_store', 'anchorfree')
    ProductLoader.load('company_store', 'anchorfree_upcharges')
    ProductLoader.load('company_store', 'anchorfree_preconfigure')

    Resque.enqueue(
      CompanyStorePrebid,
      name: store_name
    )
  end
end
