class AddShipToZipToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :ship_to_zip, :string
  end
end
