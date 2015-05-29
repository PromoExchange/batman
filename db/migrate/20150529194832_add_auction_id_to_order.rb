class AddAuctionIdToOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :auction_id, :integer
  end
end
