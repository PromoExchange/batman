class AddColumnToProductRequest < ActiveRecord::Migration
  def change
    add_column :spree_product_requests, :budget, :decimal
    add_column :spree_product_requests, :quantity, :integer
    add_column :spree_product_requests, :request_type, :string
  end
end
