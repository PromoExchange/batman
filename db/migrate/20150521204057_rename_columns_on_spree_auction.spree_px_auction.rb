# This migration comes from spree_px_auction (originally 20150514212059)
class RenameColumnsOnSpreeAuction < ActiveRecord::Migration
  def change
    rename_column :spree_auctions, :bidder_id, :buyer_id
    rename_column :spree_auctions, :descripiton, :description
  end
end
