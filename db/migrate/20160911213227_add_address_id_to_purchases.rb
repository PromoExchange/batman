class AddAddressIdToPurchases < ActiveRecord::Migration
  def change
    add_column :spree_purchases, :address_id, :integer, null: false
  end
end
