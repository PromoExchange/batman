class RemoveFluffFromImprintMethod < ActiveRecord::Migration
  def change
    remove_column :spree_imprint_methods, :created_at
    remove_column :spree_imprint_methods, :updated_at
  end
end
