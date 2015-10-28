class AddCustomerIdToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :customer_id, :integer
  end
end
