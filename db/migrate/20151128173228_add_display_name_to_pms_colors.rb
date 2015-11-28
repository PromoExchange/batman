class AddDisplayNameToPmsColors < ActiveRecord::Migration
  def change
    add_column :spree_pms_colors, :display_name, :string
  end
end
