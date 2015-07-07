class AddImprintMethodToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :imprint_method_id, :integer, null: false
  end
end
