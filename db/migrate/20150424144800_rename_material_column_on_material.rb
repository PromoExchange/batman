# 20150424144800_rename_material_column_on_material
class RenameMaterialColumnOnMaterial < ActiveRecord::Migration
  def change
    rename_column :materials, :material, :name
  end
end
