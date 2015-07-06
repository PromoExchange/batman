class AddMainColorToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :main_color, :integer
  end
end
