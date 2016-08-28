namespace :migrate do
  desc 'Migrate markup'
  task create_markup: :environment do
    seller = Spree::User.find_by_email(ENV['SELLER_EMAIL'] || 'michael.goldstein@thepromoexchange.com')
    raise "Unable to find seller [#{ENV['SELLER_EMAIL'] || 'michael.goldstein@thepromoexchange.com'}]" if seller.nil?

    suppliers = Spree::CompanyStore.pluck(:supplier_id)
    Spree::Product.where(supplier: suppliers).each do |product|
      next if product.original_supplier.nil?
      next if product.company_store.nil?

      prebid = Spree::Prebid.where(
        supplier: product.original_supplier,
        seller: seller,
        live: true
      ).first

      unless prebid.nil?
        markup = prebid.markup
        eqp = prebid.eqp
        eqp_discount = prebid.eqp_discount
      end

      Spree::Markup.where(
        supplier: product.original_supplier,
        markup: markup || 0.10,
        eqp: eqp || false,
        eqp_discount: eqp_discount || 0.0,
        live: true,
        company_store: product.company_store
      ).first_or_create
    end
  end

  namespace :user do
    desc 'Assign addresses'
    task address_assign: :environment do
      Spree::Address.all.each do |address|
        if address.ship?
          next if address.ship_user.nil?
          address.update(user_id: address.ship_user.id)
        else
          next if address.bill_user.nil?
          address.update(user_id: address.bill_user.id)
        end
        address.save!
      end
    end

    desc 'Email confirmation for existing users'
    task email_confirmation: :environment do
      Spree::User.all.each(&:confirm!)
    end
    desc 'Run all migration tasks'
    task all: [
      'environment',
      'migrate:user:address_assign',
      'email_confirmation'
    ]
  end
end
