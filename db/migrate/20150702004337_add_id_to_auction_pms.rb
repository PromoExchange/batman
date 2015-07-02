class AddIdToAuctionPms < ActiveRecord::Migration
  def change
    add_column :spree_auctions_pms_colors, :id, :primary_key
  end
end
