namespace :companystore do
  desc 'Assign new company store data'
  task assign_data: :environment do
    [
      {
        slug: 'xactly',
        email: 'xactly_cs@thepromoexchange.com',
        host: 'xactly.promox.co'
      },
      {
        slug: 'hightail',
        email: 'hightail_cs@thepromoexchange.com',
        host: 'hightail.promox.co'
      },
      {
        slug: 'netmining',
        email: 'netmining_cs@thepromoexchange.com',
        host: 'netmining.promox.co'
      },
      {
        slug: 'anchorfree',
        email: 'anchorfree_cs@thepromoexchange.com',
        host: 'anchorfree.promox.co'
      },
      {
        slug: 'pimco',
        email: 'pimco_cs@thepromoexchange.com',
        host: 'pimco.promox.co'
      }
    ].each do |assignment|
      company_store = Spree::CompanyStore.where(slug: assignment[:slug]).first
      raise "Failed to find company store #{assignment[:slug]}" if company_store.nil?

      user = Spree::User.where(email: assignment[:email]).first
      raise "Failed to find email#{assignment[:email]}" if user.nil?

      company_store.update_attributes(buyer: user, host: assignment[:host])
    end
  end

  desc 'Create Xactly company store'
  task xactly: :environment do
    user = Spree::User.where(email: 'xactly_cs@thepromoexchange.com').first
    raise 'raiseed to find user' if user.nil?

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

    Resque.enqueue(
      CompanyStorePrebid,
      name: store_name
    )

    # ASSIGN ORIGINAL SUPPLIER
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

    # LOAD PRICE CACHE
    company_store = Spree::CompanyStore.where(slug: 'xactly').first
    Spree::Product.where(supplier: company_store.supplier).each do |product|
      Spree::PriceCache.where(product: product).destroy_all
      product.refresh_price_cache
    end
  end

  desc 'Create anchor free company store'
  task anchorfree: :environment do
    user = Spree::User.where(email: 'anchorfree_cs@thepromoexchange.com').first
    raise 'raiseed to find user' if user.nil?

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

    Resque.enqueue(
      CompanyStorePrebid,
      name: store_name
    )

    # ASSIGN ORIGINAL SUPPLIER
    # Sanmar Products
    sanmar = Spree::Supplier.find_by(dc_acct_num: '100160')
    raise 'raiseed to find Sanmar Supplier' if sanmar.nil?

    sanmar_skus = [
      'AF-632418',
      'AF-5170',
      'AF-71600'
    ]

    sanmar_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: sanmar)
    end

    # Bullet Products
    bullet = Spree::Supplier.find_by(dc_acct_num: '100383')
    raise 'raiseed to find Bullet Supplier' if bullet.nil?

    bullet_skus = [
      'AF-SM-4125',
      'AF-SM-2381'
    ]

    bullet_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: bullet)
    end

    # Leeds Products
    leeds = Spree::Supplier.find_by(dc_acct_num: '100306')
    raise 'raiseed to find Leeds Supplier' if leeds.nil?

    leeds_skus = [
      'AF-7003-40',
      'AF-3250-99',
      'AF-2050-02'
    ]

    leeds_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: leeds)
    end

    # Gemline Products
    gemline = Spree::Supplier.find_by(dc_acct_num: '100306')
    raise 'raiseed to find Gemline Supplier' if gemline.nil?

    gemline_skus = [
      'AF-MOLEHRD'
    ]

    gemline_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: gemline)
    end

    # BIC Graphic Products
    bic_graphic = Spree::Supplier.where(
      name: 'BIC Graphic',
      dc_acct_num: '100104'
    ).first_or_create
    raise 'raiseed to find BIC Graphic Supplier' if bic_graphic.nil?

    bic_graphic_skus = [
      'AF-P3A3A25'
    ]

    bic_graphic_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: bic_graphic)
    end

    # Innovation Line Products
    innovation_line = Spree::Supplier.where(
      name: 'Innovation Line',
      dc_acct_num: '100108'
    ).first_or_create
    raise 'raiseed to find Innovation Line Supplier' if innovation_line.nil?

    innovation_line_skus = [
      'AF-5117'
    ]

    innovation_line_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: innovation_line)
    end

    # Jetline Products
    jetline = Spree::Supplier.where(
      name: 'Jetline',
      dc_acct_num: '120402'
    ).first_or_create
    raise 'raiseed to find Jetline Supplier' if jetline.nil?

    jetline_skus = [
      'AF-SG120'
    ]

    jetline_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: jetline)
    end

    # Quake City Caps Products
    quakecity = Spree::Supplier.where(
      name: 'Quake City Caps'
    ).first_or_create
    raise 'raiseed to find Quake City Caps Supplier' if quakecity.nil?

    quakecity_skus = [
      'AF-8500'
    ]

    quakecity_skus.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: quakecity)
    end

    # LOAD PRICE CACHE
    company_store = Spree::CompanyStore.where(slug: 'anchorfree').first
    Spree::Product.where(supplier: company_store.supplier).each do |product|
      Spree::PriceCache.where(product: product).destroy_all
      product.refresh_price_cache
    end
  end

  desc 'Create Hightail company store'
  task hightail: :environment do
    user = Spree::User.where(email: 'hightail_cs@thepromoexchange.com').first
    raise 'raiseed to find user' if user.nil?

    store_name = 'Hightail Company Store'

    # Supplier
    supplier = Spree::Supplier.where(name: store_name).first
    if supplier.nil?
      supplier = Spree::Supplier.create(
        name: 'Hightail Company Store',
        billing_address: user.bill_address,
        shipping_address: user.ship_address,
        company_store: true
      )
      supplier.save!
    end

    # Company Store
    company_store_attr = {
      name: store_name,
      display_name: 'Hightail',
      slug: 'hightail',
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
    ProductLoader.load('company_store', 'hightail')

    Resque.enqueue(
      CompanyStorePrebid,
      name: store_name
    )

    # ASSIGN ORIGINAL SUPPLIER
    # Leeds
    leeds = Spree::Supplier.find_by(dc_acct_num: '100306')
    raise 'raiseed to find leeds Supplier' if leeds.nil?

    leeds_sku = [
      'HT-8150-90'
    ]

    leeds_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: leeds)
    end

    # American Apparel
    american_apparel = Spree::Supplier.where(name: 'American Apparel').first_or_create
    raise 'raiseed to find American Apparel Supplier' if american_apparel.nil?

    american_apparel_sku = [
      'HT-F497',
      'HT-TRT497',
      'HT-2001-WHITE',
      'HT-2001-GREY'
    ]

    american_apparel_sku.each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "raiseed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: american_apparel)
    end

    # LOAD PRICE CACHE
    company_store = Spree::CompanyStore.where(slug: 'hightail').first
    Spree::Product.where(supplier: company_store.supplier).each do |product|
      Spree::PriceCache.where(product: product).destroy_all
      product.refresh_price_cache
    end
  end

  desc 'Create Netmining company store'
  task netmining: :environment do
    user = Spree::User.where(email: 'netmining_cs@thepromoexchange.com').first
    raise 'raiseed to find user' if user.nil?

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

    Resque.enqueue(
      CompanyStorePrebid,
      name: store_name
    )

    # ASSIGN ORIGINAL SUPPLIER
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

    # LOAD PRICE CACHE
    company_store = Spree::CompanyStore.where(slug: 'netmining').first
    Spree::Product.where(supplier: company_store.supplier).each do |product|
      Spree::PriceCache.where(product: product).destroy_all
      product.refresh_price_cache
    end
  end

  desc 'Create PIMCO company store'
  task pimco: :environment do
    user = Spree::User.where(email: 'pimco_cs@thepromoexchange.com').first
    raise 'raiseed to find user' if user.nil?

    store_name = 'PIMCO Company Store'

    supplier = Spree::Supplier.where(name: store_name).first_or_create(
      billing_address: user.bill_address,
      shipping_address: user.ship_address,
      company_store: true
    )

    company_store = Spree::CompanyStore.where(name: store_name).first_or_create(
      display_name: 'PIMCO',
      slug: 'pimco',
      supplier: supplier,
      buyer: user
    )

    # Load products, upcharches, and preconfigure
    ProductLoader.load('company_store', 'pimco')

    Resque.enqueue(
      CompanyStorePrebid,
      name: store_name
    )

    # Assign original supplier
    product_sku = 'PC-YRAM20'
    product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
    raise "raiseed to find product [#{product_sku}]" if product.nil?
    product.update_attributes(original_supplier: Spree::Supplier.where(name: 'Yeti').first_or_create)

    # Create Price Cache
    Spree::Product.where(supplier: company_store.supplier).each do |pr|
      Spree::PriceCache.where(product: pr).destroy_all
      pr.refresh_price_cache
    end
  end
end
