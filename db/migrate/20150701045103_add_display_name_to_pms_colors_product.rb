class AddDisplayNameToPmsColorsProduct < ActiveRecord::Migration
  def change
    add_column :spree_pms_colors_suppliers, :display_name, :string
  end
end
