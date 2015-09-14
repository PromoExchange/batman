class AddStateToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :state, :string
  end
end
