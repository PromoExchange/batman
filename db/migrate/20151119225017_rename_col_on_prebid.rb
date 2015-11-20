class RenameColOnPrebid < ActiveRecord::Migration
  def change
    rename_column :spree_prebids, :product_id, :supplier_id
  end
end
