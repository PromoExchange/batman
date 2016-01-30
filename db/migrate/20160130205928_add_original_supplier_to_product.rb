class AddOriginalSupplierToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :original_supplier_id, :integer
  end
end
