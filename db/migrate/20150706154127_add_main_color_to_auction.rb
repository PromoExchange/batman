class AddMainColorToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :main_color_id, :integer, null: false
  end
end
