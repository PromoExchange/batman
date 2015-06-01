class RemoveAuctionIdFromOrder < ActiveRecord::Migration
  def change
    remove_column :spree_orders, :auction_id
  end
end
