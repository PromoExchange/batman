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
  end
end
