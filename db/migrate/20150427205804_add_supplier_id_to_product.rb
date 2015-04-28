class AddSupplierIdToProduct < ActiveRecord::Migration
  def change
    add_column :products, :supplier_id, :integer, :null => false
  end
end
