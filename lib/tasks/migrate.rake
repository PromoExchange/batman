namespace :migrate do
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
      Spree::User.all.each do |user|
        user.confirm!
      end
    end

    desc 'Run all migration tasks'
    task all: [
      'environment',
      'migrate:user:address_assign',
      'email_confirmation'
    ]
  end
end
