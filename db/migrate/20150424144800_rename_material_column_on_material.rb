class RenameMaterialColumnOnMaterial < ActiveRecord::Migration
  def change
    rename_column :materials, :material, :name
  end
end
