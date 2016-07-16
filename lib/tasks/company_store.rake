require '../../db/company_store_loader'

def create_company_store(params)
  user = Spree::User.where(email: params[:email]).first
  raise "failed to find user: #{params[:email]}" if user.nil?

  supplier = Spree::Supplier.where(name: params[:name]).first_or_create(
    billing_address: user.bill_address,
    shipping_address: user.ship_address,
    company_store: true
  )

  Spree::CompanyStore.where(name: params[:name]).first_or_create(
    display_name: params[:display_name],
    slug: params[:slug],
    supplier: supplier,
    buyer: user
  )
end

def load_products(params)
  CompanyStoreLoader.load(params)
  Resque.enqueue(CompanyStorePrebid, name: params[:name])
end

def assign_original_supplier(config)
  config.each do |supplier_data|
    supplier = Spree::Supplier.where(supplier_data[:query]).first_or_create

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
    params = {
      display_name: 'Xactly',
      email: 'xactly_cs@thepromoexchange.com',
      slug: 'xactly',
      name: 'Xactly Company Store'
    }

    company_store = create_company_store(params)
    load_products(params)
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
    params = {
      display_name: 'Anchorfree',
      email: 'anchorfree_cs@thepromoexchange.com',
      slug: 'anchorfree',
      name: 'Anchorfree Company Store'
    }

    company_store = create_company_store(params)
    load_products(params)
    assign_original_supplier(
      [
        { query: { dc_acct_num: '100160' }, skus: ['AF-632418', 'AF-5170', 'AF-71600'] }, # Sanmar Products
        { query: { dc_acct_num: '100383' }, skus: ['AF-SM-4125', 'AF-SM-2381'] }, # Bullet Products
        { query: { dc_acct_num: '100306' }, skus: ['AF-7003-40', 'AF-3250-99', 'AF-2050-02'] }, # Leeds Products
        { query: { dc_acct_num: '100306' }, skus: ['AF-MOLEHRD'] }, # Gemline Products
        { query: { dc_acct_num: '100104' }, skus: ['AF-P3A3A25'] }, # BIC Graphic Products
        { query: { dc_acct_num: '100108' }, skus: ['AF-5117'] }, # Innovation Line Products
        { query: { dc_acct_num: '120402' }, skus: ['AF-SG120'] }, # Jetline Products
        { query: { name: 'Quake City Caps' }, skus: ['AF-8500'] } # Quake City Caps Products
      ]
    )
    create_price_cache(company_store.supplier)
  end

  desc 'Create Hightail company store'
  task hightail: :environment do
    params = {
      display_name: 'Hightail',
      email: 'hightail_cs@thepromoexchange.com',
      slug: 'hightail',
      name: 'Hightail Company Store'
    }

    company_store = create_company_store(params)
    load_products(params)
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
    params = {
      display_name: 'Netmining',
      email: 'netmining_cs@thepromoexchange.com',
      slug: 'netmining',
      name: 'Netmining Company Store'
    }

    company_store = create_company_store(params)
    load_products(params)
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
    params = {
      display_name: 'PIMCO',
      email: 'pimco_cs@thepromoexchange.com',
      slug: 'pimco',
      name: 'PIMCO Company Store'
    }

    company_store = create_company_store(params)
    load_products(params)
    assign_original_supplier([{ query: { name: 'Yeti' }, skus: ['PC-YRAM20'] }])
    create_price_cache(company_store.supplier)
  end

  desc 'Create Facebook company store'
  task facebook: :environment do
    params = {
      display_name: 'Facebook',
      email: 'facebook_cs@thepromoexchange.com',
      slug: 'facebook',
      name: 'Facebook Company Store'
    }

    company_store = create_company_store(params)
    load_products(params)
    assign_original_supplier([{ query: { name: 'Brunswick' }, skus: ['FB-BRU181'] }])
    create_price_cache(company_store.supplier)
  end

  desc 'Create Pavia company store'
  task pavia: :environment do
    params = {
      display_name: 'Pavia',
      email: 'lindsay.bertsch@paviasystems.com',
      slug: 'pavia',
      name: 'Pavia Company Store'
    }

    company_store = create_company_store(params)
    load_products(params)
    assign_original_supplier(
      [
        { query: { dc_acct_num: '100257' }, skus: ['PA-40060'] },
        { query: { dc_acct_num: '100108' }, skus: ['PA-5117'] },
        { query: { name: 'Pinnacle' }, skus: ['PA-SM-4125'] },
        {
          query: { dc_acct_num: '100306' },
          skus: ['PA-7120-18', 'PA-7199-32', 'PA-1621-11', 'PA-7199-60', 'PA-9350-22']
        },
        { query: { dc_acct_num: '100160' }, skus: ['PA-3250-99'] },
        { query: { name: 'Deluxe' }, skus: ['PA-SM-9734'] },
        { query: { name: 'Magnetic Attractions' }, skus: ['PA-ARI251'] },
        { query: { name: 'Imprint Items' }, skus: ['PA-JK-7000'] },
        { query: { name: 'Leader' }, skus: ['PA-98070'] },
        { query: { name: 'Columbia' }, skus: ['PA-6223'] }
      ]
    )
    create_price_cache(company_store.supplier)
  end

  desc 'Create Longboard company store'
  task longboard: :environment do
    params = {
      display_name: 'Longboard',
      email: 'kate@longboard-am.com',
      slug: 'longboard',
      name: 'Longboard Company Store'
    }

    company_store = create_company_store(params)
    load_products(params)
    assign_original_supplier(
      [
        {
          query: { dc_acct_num: '100306' },
          skus: [
            'LB-9350-78',
            'LB-5300-68',
            'LB-4004-04',
            'LB-4004-19',
            'LB-4004-01',
            'LB-9860-11',
            'LB-4004-11',
            'LB-2090-03',
            'LB-6050-51',
            'LB-9860-69',
            'LB-6050-76',
            'LB-6050-78'
          ]
        },
        { query: { name: 'Spector' }, skus: ['LB-G3112'] },
        { query: { name: 'ETS Express' }, skus: ['LB-33162'] },
        { query: { name: 'Chameleon Like' }, skus: ['LB-VPM'] },
        { query: { name: 'Marmot' }, skus: ['LB-98070'] },
        { query: { name: 'Columbia' }, skus: ['LB-6223'] },
        { query: { name: 'Prime Line' }, skus: ['LB-PL-4525'] }
      ]
    )
    create_price_cache(company_store.supplier)
  end
end
