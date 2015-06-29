class RemoveDescriptionFromAuction < ActiveRecord::Migration
  def change
    remove_column :spree_auctions, :description
  end
end
