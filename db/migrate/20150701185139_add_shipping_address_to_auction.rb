class AddShippingAddressToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :shipping_address_id, :integer, null: false
  end
end
