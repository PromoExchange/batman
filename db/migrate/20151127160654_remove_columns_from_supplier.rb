class RemoveColumnsFromSupplier < ActiveRecord::Migration
  def change
    remove_column :spree_suppliers, :description, :string
    remove_column :spree_suppliers, :created_at, :datetime
    remove_column :spree_suppliers, :updated_at, :datetime
  end
end
