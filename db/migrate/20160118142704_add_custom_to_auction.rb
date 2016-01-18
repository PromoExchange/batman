class AddCustomToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :custom, :boolean
  end
end
