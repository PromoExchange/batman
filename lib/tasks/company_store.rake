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
    create_price_cache(company_store.supplier)
  end

  desc 'Create VFA company store'
  task vfa: :environment do
    params = {
      display_name: 'Venture for America',
      email: 'helen@ventureforamerica.org',
      slug: 'vfa',
      name: 'VFA Company Store'
    }

    company_store = create_company_store(params)
    load_products(params)
    create_price_cache(company_store.supplier)
  end

  desc 'copy products from one store to another'
  task :copy_products, [:slug1, :slug2] => :environment do |_t, args|
    base_store = Spree::CompanyStore.find_by(slug: args[:slug1])
    next_store = Spree::CompanyStore.find_by(slug: args[:slug2])

    base_store.products.each do |product|
      new_product = product.dup
      new_product.sku = "#{args[:slug1]}-#{product.sku}"
      new_product.supplier = next_store.supplier
      new_product.price = 1.0
      new_product.save!
    end
  end
end
