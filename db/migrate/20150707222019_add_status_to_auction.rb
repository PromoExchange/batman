class AddStatusToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :status, :string, default: :open
  end
end
