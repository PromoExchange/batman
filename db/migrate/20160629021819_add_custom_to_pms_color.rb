class AddCustomToPmsColor < ActiveRecord::Migration
  def change
    add_column :spree_pms_colors, :custom, :boolean, default: false
  end
end
