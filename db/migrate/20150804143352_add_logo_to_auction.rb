class AddLogoToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :logo_id, :integer
  end
end
