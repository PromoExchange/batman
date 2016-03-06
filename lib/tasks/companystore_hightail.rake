namespace :companystore do
  desc 'Create Hightail company store'
  task hightail: :environment do
    user = Spree::User.where(email: 'lindsey.robinson@hightail.com').first

    # User
    if user.nil?
      role = Spree::Role.where(name: 'buyer').first_or_create

      user = Spree::User.create(
        email: 'lindsey.robinson@hightail.com',
        login: 'lindsey.robinson@hightail.com',
        password: 'password123',
        password_confirmation: 'password123'
      )

      user.spree_roles << role
      user.generate_spree_api_key!

      country = Spree::Country.where(iso3: 'USA').first
      state = Spree::State.where(name: 'California').first

      user.ship_address = Spree::Address.create(
        company: 'Hightail',
        firstname: 'Lindsey',
        lastname: 'Robinson',
        address1: '1919 S. Bascom Ave, Suite 650',
        city: 'Campbell',
        zipcode: '95008',
        state_id: state.id,
        country_id: country.id,
        phone: '8665587363'
      )

      user.bill_address = Spree::Address.create(
        company: 'Hightail',
        firstname: 'Lindsey',
        lastname: 'Robinson',
        address1: '1919 S. Bascom Ave, Suite 650',
        city: 'Campbell',
        zipcode: '95008',
        state_id: state.id,
        country_id: country.id,
        phone: '8665587363'
      )
      user.save!
      user.confirm!
    end

    # Add Logo
    if user.logos.where(custom: true).count == 0
      logo_file_name = File.join(Rails.root, 'db/company_store_data/hightail_logo_black.pdf')
      user.logos << Spree::Logo.create!(user: user, logo_file: open(logo_file_name), custom: true)
    end

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
    ProductLoader.load('company_store', 'hightail_upcharges')
    ProductLoader.load('company_store', 'hightail_preconfigure')

    Resque.enqueue(
      CompanyStorePrebid,
      name: store_name
    )
  end
end
