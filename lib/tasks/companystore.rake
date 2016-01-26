
namespace :companystore do
  desc 'Fix Company Store Bids'
  task fixanchorfree: :environment do
    # HACK: Pre Demo price adjustments
    company_store = Spree::CompanyStore.where(slug: 'anchorfree').first
    products = Spree::Product.where(supplier: company_store.supplier).pluck(:id)
    auctions = Spree::Auction.where(product_id: products, state: :custom_auction)
    auctions.each do |auction|
      line_item = auction.bids.first.order.line_items.first
      if auction.product.sku == 'AF-7003-40'
        line_item.price = 487.40
      elsif auction.product.sku == 'AF-3250-99'
        line_item.price = 628.36
      elsif auction.product.sku == 'AF-2050-02'
        line_item.price = 406.26
      elsif auction.product.sku == 'AF-SM-4125'
        line_item.price = 299.74
      elsif auction.product.sku == 'AF-MOLEHRD'
        line_item.price = 566.47
      elsif auction.product.sku == 'AF-8500'
        line_item.price = 151.83
      elsif auction.product.sku == 'AF-SM-2381'
        line_item.price = 373.48
      elsif auction.product.sku == 'AF-P3A3A25'
        line_item.price = 243.06
      elsif auction.product.sku == 'AF-5117'
        line_item.price = 181.40
      elsif auction.product.sku == 'AF-SG120'
        line_item.price = 223.44
      elsif auction.product.sku == 'AF-632418'
        line_item.price = 882.89
      elsif auction.product.sku == 'AF-5170'
        line_item.price = 258.38
      elsif auction.product.sku == 'AF-71600'
        line_item.price = 461.69
      end
      line_item.save!
      order_updater = Spree::OrderUpdater.new(auction.bids.first.order)
      order_updater.update
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
        company: 'Anchor Free',
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
        company: 'Anchor Free',
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
