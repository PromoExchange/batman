class AddReferenceToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :reference, :string
    add_index :spree_auctions, :reference, unique: true
  end
end
