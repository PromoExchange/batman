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
  CompanyStoreLoader.load!(params)
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
        { query: { dc_acct_num: '100306', name: "Leed's / Leeds" }, skus: ['XA-8150-85', 'XA-7120-15'] },
        {
          query: { dc_acct_num: '100383', name: 'Bullet' },
          skus: ['XA-SM-4125']
        },
        { query: { dc_acct_num: '100257', name: 'Gemline' }, skus: ['XA-40061'] },
        { query: { name: 'River\'s End Trading' }, skus: ['XA-6223'] },
        { query: { name: 'American Apparel' }, skus: ['XA-F497', 'XA-2001-WHITE'] },
        {
          query: { dc_acct_num: '100108', name: 'Innovation Line' },
          skus: ['XA-5117']
        },
        { query: { name: 'Next Level' }, skus: ['XA-6240-SXL', 'XA-6640-SXL'] },
        { query: { dc_acct_num: '101760', name: '3M Promotional Markets' }, skus: ['XA-PD46P-25'] },
        { query: { dc_acct_num: '101044', name: 'Logomark, Inc.' }, skus: ['XA-BA2300'] },
        { query: { dc_acct_num: '101371', name: 'DIGISPEC' }, skus: ['XA-BTR8'] },
        { query: { dc_acct_num: '446654', name: 'Clothpromotions Plus' }, skus: ['XA-CPP5579'] },
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
        {
          query: { dc_acct_num: '100160', name: 'SanMar' },
          skus: ['AF-632418', 'AF-5170', 'AF-71600']
        }, # Sanmar Products
        { query: { dc_acct_num: '100383', name: 'Bullet' }, skus: ['AF-SM-4125', 'AF-SM-2381'] }, # Bullet Products
        {
          query: { dc_acct_num: '100306', name: "Leed's / Leeds" },
          skus: ['AF-7003-40', 'AF-3250-99', 'AF-2050-02']
        }, # Leeds Products
        { query: { dc_acct_num: '100306', name: "Leed's / Leeds" }, skus: ['AF-MOLEHRD'] }, # Gemline Products
        { query: { dc_acct_num: '100104', name: 'BIC Graphic' }, skus: ['AF-P3A3A25'] }, # BIC Graphic Products
        { query: { dc_acct_num: '100108', name: 'Innovation Line' }, skus: ['AF-5117'] }, # Innovation Line Products
        { query: { dc_acct_num: '120402', name: 'Jetline' }, skus: ['AF-SG120'] }, # Jetline Products
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
        { query: { dc_acct_num: '100306', name: "Leed's / Leeds" }, skus: ['HT-8150-90'] }, # Leeds Products
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
        { query: { dc_acct_num: '100746', name: 'Ariel Premium Supply, Inc.' }, skus: ['NM-EOS-LP15'] },
        { query: { name: 'Brand Box' }, skus: ['NM-1148WM'] },
        {
          query: { dc_acct_num: '100383', name: 'Bullet' },
          skus: ['NM-SM-6319']
        },
        {
          query: { dc_acct_num: '100257', name: 'Gemline' },
          skus: ['NM-40061']
        },
        { query: { dc_acct_num: '100160', name: 'SanMar' }, skus: ['NM-354055'] },
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
      email: 'robin.fremont@pimco.com',
      slug: 'pimco',
      name: 'PIMCO Company Store'
    }

    company_store = create_company_store(params)
    load_products(params)
    assign_original_supplier(
      [
        { query: { name: 'Yeti' }, skus: ['PC-YRAM20'] }
      ]
    )
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
        { query: { dc_acct_num: '100257', name: 'Gemline' }, skus: ['PA-40060'] },
        { query: { dc_acct_num: '100108', name: 'Innovation Line' }, skus: ['PA-5117'] },
        { query: { name: 'Pinnacle' }, skus: ['PA-SM-4125'] },
        {
          query: { dc_acct_num: '100306', name: "Leed's / Leeds" },
          skus:
          [
            'PA-7120-18',
            'PA-7199-32',
            'PA-1621-11',
            'PA-7199-60',
            'PA-9350-22',
            'PA-1624-07',
            'PA-1622-71',
            'PA-1624-78'
          ]
        },
        { query: { dc_acct_num: '100160', name: 'SanMar' }, skus: ['PA-3250-99'] },
        { query: { name: 'Deluxe' }, skus: ['PA-SM-9734'] },
        { query: { name: 'Magnetic Attractions' }, skus: ['PA-ARI251'] },
        { query: { name: 'Imprint Items' }, skus: ['PA-JK-7000'] },
        { query: { name: 'Leader' }, skus: ['PA-98070'] },
        { query: { name: 'Columbia' }, skus: ['PA-6223'] },
        { query: { name: 'Snugz' }, skus: ['PA-LS34M.ZIP', 'PA-LP34M.ZIP'] },
        {
          query: { dc_acct_num: '100383', name: 'Bullet' },
          skus: ['PA-SM-2404', 'PA-SM-2381', 'PA-SM-2428', 'PA-SM-8045']
        },
        { query: { dc_acct_num: '100306', name: "Leed's / Leeds" }, skus: ['PA-6002-17', 'PA-6002-55', 'PA-1067-01'] }
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
          query: { dc_acct_num: '100306', name: "Leed's / Leeds" },
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

  desc 'Create Bastide company store'
  task bastide: :environment do
    params = {
      display_name: 'Bastide',
      email: 'mlin@bastide.com',
      slug: 'bastide',
      name: 'Bastide Company Store'
    }

    company_store = create_company_store(params)
    load_products(params)
    assign_original_supplier(
      [
        {
          query: { dc_acct_num: '112242', name: 'Hirsch Gift' },
          skus: ['BA-T550', 'BA-T515', 'BA-T5580', 'BA-T501BK', 'BA-T523', 'BA-T524']
        },
        {
          query: { dc_acct_num: '100306', name: "Leed's / Leeds" },
          skus: ['BA-1690-49', 'BA-1695-05', 'BA-1690-63', 'BA-1693-86', 'BA-1691-61']
        }
      ]
    )
    create_price_cache(company_store.supplier)
  end

  desc 'Create AQR company store'
  task aqr: :environment do
    params = {
      display_name: 'AQR',
      email: 'susanne.quattrochi@aqr.com',
      slug: 'aqr',
      name: 'AQR Company Store'
    }

    company_store = create_company_store(params)
    load_products(params)
    assign_original_supplier(
      [
        { query: { name: 'Ball Pro' }, skus: ['AQR-TPVN'] },
        { query: { dc_acct_num: '100160', name: 'SanMar' }, skus: ['AQR-5250'] },
        { query: { name: 'Alphabroder' }, skus: ['AQR-98070', 'AQR-98140'] },
        { query: { dc_acct_num: '100306', name: "Leed's / Leeds" }, skus: ['AQR-1015-74'] },
        { query: { dc_acct_num: '100383', name: 'Bullet' }, skus: ['AQR-SM-4840'] }
      ]
    )
    create_price_cache(company_store.supplier)
  end
end
