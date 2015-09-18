class RemoveStatusFromAuction < ActiveRecord::Migration
  def change
    remove_column :spree_auctions, :status
  end
end
