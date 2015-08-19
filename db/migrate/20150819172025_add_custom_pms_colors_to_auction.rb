class AddCustomPmsColorsToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :custom_pms_colors, :string
  end
end
