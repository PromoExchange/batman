class AddUserIdToAddress < ActiveRecord::Migration
  def change
    add_column :spree_addresses, :user_id, :integer

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
