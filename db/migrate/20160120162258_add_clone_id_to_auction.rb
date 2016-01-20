class AddCloneIdToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :clone_id, :integer
  end
end
