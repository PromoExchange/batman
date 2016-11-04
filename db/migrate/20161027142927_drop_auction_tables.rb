class DropAuctionTables < ActiveRecord::Migration
  def change
    drop_table :spree_auctions
    drop_table :spree_bids
    drop_table :spree_prebids
    drop_table :spree_price_caches
  end
end
