class AddTitleToProductRequest < ActiveRecord::Migration
  def change
    add_column :spree_product_requests, :title, :string
  end
end
