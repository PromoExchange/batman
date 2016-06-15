namespace :companystore do
  desc 'Create PIMCO company store'
  task pimco: :environment do
    user = Spree::User.where(email: 'pimco_cs@thepromoexchange.com').first
    fail 'Failed to find user' if user.nil?

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
    original_supplier = Spree::Supplier.where(name: 'Yeti').first_or_create
    fail 'Failed to find Supplier: Yeti' if original_supplier.blank?

    product_sku = 'PC-YRAM20'
    product = Spree::Product.joins(:master).where("spree_variants.sku='#{product_sku}'").first
    fail "Failed to find product [#{product_sku}]" if product.nil?
    product.update_attributes(original_supplier: supplier)

    # Create Price Cache
    Spree::Product.where(supplier: company_store.supplier).each do |pr|
      Spree::PriceCache.where(product: pr).destroy_all
      prrefresh_price_cache
    end
  end
end
