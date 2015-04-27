class RenameBrandColumnToName < ActiveRecord::Migration
  def change
    rename_column :brands, :brand, :name
  end
end
