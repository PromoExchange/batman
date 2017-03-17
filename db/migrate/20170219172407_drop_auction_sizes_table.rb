class DropAuctionSizesTable < ActiveRecord::Migration
  def change
    drop_table :spree_auction_sizes
    drop_table :spree_auctions_pms_colors
    drop_table :spree_auctions_users
    drop_table :spree_reviews
  end
end
