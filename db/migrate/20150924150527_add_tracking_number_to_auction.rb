class AddTrackingNumberToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :tracking_number, :string
  end
end
