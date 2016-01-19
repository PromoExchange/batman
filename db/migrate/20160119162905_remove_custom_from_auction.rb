class RemoveCustomFromAuction < ActiveRecord::Migration
  def change
    remove_column :spree_auctions, :custom, :boolean
  end
end
