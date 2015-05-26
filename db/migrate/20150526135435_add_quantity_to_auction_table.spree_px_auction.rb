# This migration comes from spree_px_auction (originally 20150524181710)
class AddQuantityToAuctionTable < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :quantity, :integer, null: false
  end
end
