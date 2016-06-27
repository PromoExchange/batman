def create_company_store(email, name, display_name, slug)
  user = Spree::User.where(email: email).first
  raise "failed to find user: #{email}" if user.nil?

  supplier = Spree::Supplier.where(name: name).first_or_create(
    billing_address: user.bill_address,
    shipping_address: user.ship_address,
    company_store: true
  )

  Spree::CompanyStore.where(name: name).first_or_create(
    display_name: display_name,
    slug: slug,
    supplier: supplier,
    buyer: user
  )
end

def load_products(slug, store_name)
  ProductLoader.load('company_store', slug)
  Resque.enqueue(
    CompanyStorePrebid,
    name: store_name
  )
end

def assign_original_supplier(config)
  config.each do |supplier_data|
    supplier = Spree::Supplier.where(supplier_data[:query]).first
    raise "failed to find Supplier: #{supplier_data[:query]}" if supplier.nil?

    supplier_data[:skus].each do |product_sku|
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
      raise "failed to find product [#{product_sku}]" if product.nil?
      product.update_attributes(original_supplier: supplier)
    end
  end
end

def create_price_cache(supplier)
  Spree::Product.where(supplier: supplier).each do |product|
    Spree::PriceCache.where(product: product).destroy_all
    product.refresh_price_cache
  end
end

namespace :company_store do
  desc 'Create Xactly company store'
  task xactly: :environment do
    store_name = 'Xactly Company Store'
    slug = 'xactly'
    company_store = create_company_store('xactly_cs@thepromoexchange.com', store_name, 'Xactly', slug)
    load_products(slug, store_name)
    assign_original_supplier(
      [
        { query: { dc_acct_num: '100306' }, skus: ['XA-8150-85', 'XA-7120-15'] },
        { query: { dc_acct_num: '100383' }, skus: ['XA-SM-4125'] },
        { query: { dc_acct_num: '100257' }, skus: ['XA-40061'] },
        { query: { name: 'River\'s End Trading' }, skus: ['XA-6223'] },
        { query: { name: 'American Apparel' }, skus: ['XA-F497', 'XA-2001-WHITE'] },
        { query: { dc_acct_num: '100108' }, skus: ['XA-5117'] },
        { query: { name: 'Next Level' }, skus: ['XA-6240-SXL', 'XA-6640-SXL'] },
        { query: { dc_acct_num: '101760' }, skus: ['XA-PD46P-25'] },
        { query: { dc_acct_num: '101044' }, skus: ['XA-BA2300'] },
        { query: { dc_acct_num: '101371' }, skus: ['XA-BTR8'] },
        { query: { dc_acct_num: '446654' }, skus: ['XA-CPP5579'] },
        { query: { name: 'Alpi International' }, skus: ['XA-20099'] }
      ]
    )
    create_price_cache(company_store.supplier)
  end

  desc 'Create anchor free company store'
  task anchorfree: :environment do
    store_name = 'Anchorfree Company Store'
    slug = 'anchorfree'
    company_store = create_company_store('anchorfree_cs@thepromoexchange.com', store_name, 'Anchorfree', slug)
    products = [
      { query: { dc_acct_num: '100160' }, skus: ['AF-632418', 'AF-5170', 'AF-71600'] }, # Sanmar Products
      { query: { dc_acct_num: '100383' }, skus: ['AF-SM-4125', 'AF-SM-2381'] }, # Bullet Products
      { query: { dc_acct_num: '100306' }, skus: ['AF-7003-40', 'AF-3250-99', 'AF-2050-02'] }, # Leeds Products
      { query: { dc_acct_num: '100306' }, skus: ['AF-MOLEHRD'] }, # Gemline Products
      { query: { dc_acct_num: '100104' }, skus: ['AF-P3A3A25'] }, # BIC Graphic Products
      { query: { dc_acct_num: '100108' }, skus: ['AF-5117'] }, # Innovation Line Products
      { query: { dc_acct_num: '120402' }, skus: ['AF-SG120'] }, # Jetline Products
      { query: { name: 'Quake City Caps' }, skus: ['AF-8500'] } # Quake City Caps Products
    ]
    load_products(slug, store_name)
    assign_original_supplier(products)
    create_price_cache(company_store.supplier)
  end

  desc 'Create Hightail company store'
  task hightail: :environment do
    store_name = 'Hightail Company Store'
    slug = 'hightail'
    company_store = create_company_store('hightail_cs@thepromoexchange.com', store_name, 'Hightail', slug)
    load_products(slug, store_name)
    assign_original_supplier(
      [
        { query: { dc_acct_num: '100306' }, skus: ['HT-8150-90'] }, # Leeds Products
        { query: { name: 'American Apparel' }, skus: ['HT-F497', 'HT-TRT497', 'HT-2001-WHITE', 'HT-2001-GREY'] } # AA
      ]
    )
    create_price_cache(company_store.supplier)
  end

  desc 'Create Netmining company store'
  task netmining: :environment do
    store_name = 'Netmining Company Store'
    slug = 'netmining'
    company_store = create_company_store('netmining_cs@thepromoexchange.com', store_name, 'Netmining', slug)
    load_products(slug, store_name)
    assign_original_supplier(
      [
        { query: { dc_acct_num: '100746' }, skus: ['NM-EOS-LP15'] },
        { query: { name: 'Brand Box' }, skus: ['NM-1148WM'] },
        { query: { dc_acct_num: '100383' }, skus: ['NM-SM-6319'] },
        { query: { dc_acct_num: '100257' }, skus: ['NM-40061'] },
        { query: { dc_acct_num: '100160' }, skus: ['NM-354055'] },
        { query: { name: 'Marmot' }, skus: ['NM-98140'] },
        { query: { name: 'American Apparel' }, skus: ['NM-2001'] }
      ]
    )
    create_price_cache(company_store.supplier)
  end

  desc 'Create PIMCO company store'
  task pimco: :environment do
    store_name = 'PIMCO Company Store'
    slug = 'pimco'
    company_store = create_company_store('pimco_cs@thepromoexchange.com', store_name, 'PIMCO', slug)
    load_products(slug, store_name)
    assign_original_supplier([{ query: { name: 'Yeti' }, skus: ['PC-YRAM20'] }])
    create_price_cache(company_store.supplier)
  end

  desc 'Create Facebook company store'
  task pimco: :environment do
    store_name = 'Facebook Company Store'
    slug = 'facebook'
    company_store = create_company_store('facebook_cs@thepromoexchange.com', store_name, 'Facebook', slug)
    load_products(slug, store_name)
    assign_original_supplier([{ query: { name: 'Brunswick' }, skus: ['FB-BRU181'] }])
    create_price_cache(company_store.supplier)
  end
end
