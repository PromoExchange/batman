# This migration comes from spree_px_auction (originally 20150520160326)
class RemoveSellerIdFromAuctions < ActiveRecord::Migration
  def change
    remove_column :spree_auctions, :seller_id, :integer
  end
end
