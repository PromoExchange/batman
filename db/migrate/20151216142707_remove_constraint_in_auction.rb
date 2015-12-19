class RemoveConstraintInAuction < ActiveRecord::Migration
  def change
    change_column :spree_auctions, :shipping_address_id, :integer, null: true
    change_column :spree_auctions, :buyer_id, :integer, null: true
    change_column :spree_auctions, :payment_method, :string, null: true
  end
end
