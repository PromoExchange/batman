# This migration comes from spree_px_auction (originally 20150524183327)
class AddImprintDescriptionToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :imprint_description, :string
  end
end
