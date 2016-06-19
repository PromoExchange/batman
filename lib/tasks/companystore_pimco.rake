namespace :companystore do
  task pimco: 'pimco:all'

  namespace :pimco do
    desc 'Default task for pimco'
    task all: [:load, :assign]

    desc 'Assign Markup to Pimco'
    task assign: :environment do
      supplier = Spree::Supplier.find_by_name('Yeti')
      raise 'Failed to find YETI supplier' if supplier.nil?

      company_store = Spree::CompanyStore.find_by_slug('pimco')
      raise 'Failed to find PIMCO CompanyStore' if company_store.nil?

      Spree::Markup.where(
        supplier: supplier,
        markup: 0.10,
        eqp: false,
        eqp_discount: 0.0,
        live: true,
        company_store: company_store
      ).first_or_create
    end

    desc 'Create PIMCO company store'
    task load: :environment do
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
end
