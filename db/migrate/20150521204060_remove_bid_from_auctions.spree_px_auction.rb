# This migration comes from spree_px_auction (originally 20150520160412)
class RemoveBidFromAuctions < ActiveRecord::Migration
  def change
    remove_column :spree_auctions, :bid, :decimal
  end
end
