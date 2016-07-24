namespace :migrate do
  desc 'Migrate markup'
  task create_markup: :environment do
    suppliers = Spree::CompanyStore.pluck(:supplier_id)
    Spree::Product.where(supplier: suppliers).each do |product|
      next if product.original_supplier.nil?
      next if product.company_store.nil?
      Spree::Markup(
        supplier: product.original_supplier,
        markup: 0.10,
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
          address.update(user_id: address.ship_user.id)
        else
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
