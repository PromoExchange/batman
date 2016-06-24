namespace :companystore do
  desc 'Add Xactly address'
  task add_xactly_address: :environment do
    exit if Spree::Address.exists?(
      company: 'Xactly',
      address1: 'YRC - T3 Expo',
      address2: '400 Grandview Drive - Ste. C',
      city: 'South San Francisco',
      zipcode: '94080'
    )

    user = Spree::User.where(email: 'mkuh@xactlycorp.com').first

    country = Spree::Country.where(iso3: 'USA').first
    state = Spree::State.where(name: 'California').first

    address = Spree::Address.where(
      company: 'Xactly',
      firstname: 'Marlene',
      lastname: 'Kuh',
      address1: 'YRC - T3 Expo',
      address2: '400 Grandview Drive - Ste. C',
      city: 'South San Francisco',
      zipcode: '94080',
      state_id: state.id,
      country_id: country.id,
      phone: '4082921153'
    ).first_or_create
    user.addresses << address
    user.save!
  end

  desc 'Fix Xactly PMS'
  task fix_xactly_pms: :environment do
    company_store = Spree::CompanyStore.where(slug: 'xactly').first
    Spree::Product.where(supplier: company_store.supplier).each do |p|
      preconfigure = Spree::Preconfigure.where(product: p).first
      preconfigure.update_attributes(custom_pms_colors: '166 C')
    end
  end

  desc 'Fix Xactly images'
  task fix_xactly_images: :environment do
    xactly_products = [
      'XA-PD46P-25',
      'XA-BA2300',
      'XA-BTR8',
      'XA-CPP5579'
    ]

    xactly_products.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      product.images.destroy_all
      image_path = File.join(Rails.root, "db/product_images/xactly/#{product_sku}.jpg")
      product.images << Spree::Image.create!(
        attachment: open(image_path),
        viewable: product
      )
    end
  end

  desc 'Delete part 2 products'
  task delete_2_products: :environment do
    # xactly_2_products = [
    #   'XA-6240-SXL',
    #   'XA-6640-SXL',
    #   'XA-PD46P-25',
    #   'XA-BA2300',
    #   'XA-BTR8',
    #   'XA-CPP5579'
    # ]
    xactly_2_products = [
      'XA-20099'
    ]

    xactly_2_products.each do |sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{sku}'").first
      if product.nil?
        puts "ERROR: raiseed to find product: #{sku}"
      else
        product.images.destroy_all
        product.destroy
      end
    end
  end

  desc 'Fix Cellphone Wallet'
  task fix_cell_wallet: :environment do
    product = Spree::Product.joins(:master).where("spree_variants.sku='XA-5117'").first
    product.images.destroy_all
    image_path = File.join(Rails.root, 'db/product_images/xactly/XA-5117.jpg')
    product.images << Spree::Image.create!(
      attachment: open(image_path),
      viewable: product
    )
  end

  desc 'Fix Quake City'
  task fix_quake_city: :environment do
    quake_city = Spree::Supplier.where(name: 'Quaker City Caps').first
    quake_city.update_attributes(name: 'Quake City Caps') if quake_city.present?
  end

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
    raise 'raiseed to find leeds Supplier' if leeds.nil?

    leeds_sku = [
      'XA-8150-85',
      'XA-7120-15'
    ]

    leeds_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: leeds)
    end

    # Bullet
    bullet = Spree::Supplier.find_by(dc_acct_num: '100383')
    raise 'raiseed to find gemline Supplier' if bullet.nil?

    bullet_sku = [
      'XA-SM-4125'
    ]

    bullet_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: bullet)
    end

    # Gemline
    gemline = Spree::Supplier.find_by(dc_acct_num: '100257')
    raise 'raiseed to find gemline Supplier' if gemline.nil?

    gemline_sku = [
      'XA-40061'
    ]

    gemline_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: gemline)
    end

    # Rivers End Trading
    rivers_end_trading = Spree::Supplier.where(name: 'River\'s End Trading').first_or_create
    raise 'raiseed to find River\'s End Tradomg Supplier' if rivers_end_trading.nil?

    rivers_end_sku = [
      'XA-6223'
    ]

    rivers_end_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: rivers_end_trading)
    end

    # American Apparel
    american_apparel = Spree::Supplier.where(name: 'American Apparel').first_or_create
    raise 'raiseed to find American Apparel Supplier' if american_apparel.nil?

    american_apparel_sku = [
      'XA-F497',
      'XA-2001-WHITE'
    ]

    american_apparel_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: american_apparel)
    end

    # Innovation line
    innovation_line = Spree::Supplier.where(
      name: 'Innovation Line',
      dc_acct_num: '100108'
    ).first_or_create
    raise 'raiseed to find Innovation Line Supplier' if innovation_line.nil?

    innovation_line_skus = [
      'XA-5117'
    ]

    innovation_line_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: innovation_line)
    end
  end

  desc 'Assign orginal xactly 2 suppliers'
  task xactly_original2: :environment do
    # Next Level
    next_level = Spree::Supplier.where(name: 'Next Level').first_or_create
    raise 'raiseed to find Next Level Supplier' if next_level.nil?

    next_level_sku = [
      'XA-6240-SXL',
      'XA-6640-SXL'
    ]

    next_level_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: next_level)
    end

    # 3M
    m3 = Spree::Supplier.where(
      name: '3M Promotional Markets',
      dc_acct_num: '101760'
    ).first_or_create
    raise 'raiseed to find 3M Supplier' if m3.nil?

    m3_sku = [
      'XA-PD46P-25'
    ]

    m3_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: m3)
    end

    # Logomark
    logomark = Spree::Supplier.where(
      name: 'Logomark, Inc.',
      dc_acct_num: '101044'
    ).first_or_create
    raise 'raiseed to find Logomark Supplier' if logomark.nil?

    logomark_sku = [
      'XA-BA2300'
    ]

    logomark_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: logomark)
    end

    # Digispec
    digispec = Spree::Supplier.where(
      name: 'DIGISPEC',
      dc_acct_num: '101371'
    ).first_or_create
    raise 'raiseed to find Digispec Supplier' if digispec.nil?

    digispec_sku = [
      'XA-BTR8'
    ]

    digispec_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: digispec)
    end

    # Cloth Promotions
    cloth_promotions = Spree::Supplier.where(
      name: 'Clothpromotions Plus',
      dc_acct_num: '446654'
    ).first_or_create
    raise 'raiseed to find Cloth Promotions Supplier' if cloth_promotions.nil?

    cloth_promotions_sku = [
      'XA-CPP5579'
    ]

    cloth_promotions_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: cloth_promotions)
    end

    # Alpi International
    alpi_international = Spree::Supplier.where(name: 'Alpi International').first_or_create
    raise 'raiseed to find Alpi International Supplier' if alpi_international.nil?

    alpi_international_skus = [
      'XA-20099'
    ]

    alpi_international_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: alpi_international)
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
        phone: '4082921153'
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
        phone: '4082921153'
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
    ProductLoader.load('company_store', 'xactly')
    ProductLoader.load('company_store', 'xactly_upcharges')
    ProductLoader.load('company_store', 'xactly_preconfigure')

    Resque.enqueue(
      CompanyStorePrebid,
      name: store_name
    )
  end

  desc 'Create Xactly2 company store'
  task xactly2: :environment do
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
        phone: '4082921153'
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
        phone: '4082921153'
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
    ProductLoader.load('company_store', 'xactly2')
    ProductLoader.load('company_store', 'xactly_upcharges2')
    ProductLoader.load('company_store', 'xactly_preconfigure2')

    Resque.enqueue(
      CompanyStorePrebid,
      name: store_name
    )
  end
end