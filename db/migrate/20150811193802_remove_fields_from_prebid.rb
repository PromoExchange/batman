class RemoveFieldsFromPrebid < ActiveRecord::Migration
  def change
    remove_column :spree_prebids, :description
    remove_column :spree_prebids, :created_at
    remove_column :spree_prebids, :updated_at
  end
end
