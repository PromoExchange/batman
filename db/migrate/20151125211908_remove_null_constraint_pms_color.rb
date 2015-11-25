class RemoveNullConstraintPmsColor < ActiveRecord::Migration
  def change
    change_column :spree_pms_colors, :pantone, :string, :null => true
  end
end
