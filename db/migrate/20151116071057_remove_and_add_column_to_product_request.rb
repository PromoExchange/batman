class RemoveAndAddColumnToProductRequest < ActiveRecord::Migration
  def change
    remove_column :spree_product_requests, :budget, :decimal
    add_column :spree_product_requests, :budget_from, :decimal, :default => 0.0
    add_column :spree_product_requests, :budget_to, :decimal, :default => 0.0
  end
end
