# This migration comes from spree_px_auction (originally 20150525173802)
class AddAcceptRushToSpreeAuctions < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :accept_rush, :boolean ,:default => false
  end
end
