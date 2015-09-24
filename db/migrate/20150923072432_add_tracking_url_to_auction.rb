class AddTrackingUrlToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :tracking_url, :string
  end
end
