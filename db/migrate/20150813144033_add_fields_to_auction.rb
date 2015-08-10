class AddFieldsToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :pms_color_match, :boolean, default: false
    add_column :spree_auctions, :change_ink, :boolean, default: false
    add_column :spree_auctions, :no_under_over, :boolean, default: false
  end
end
