class AddShippingDataToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :shipping_quantity, :string
    add_column :spree_products, :shipping_weight, :string
    add_column :spree_products, :shipping_dimensions, :string
    add_column :spree_products, :originating_zip, :string
  end
end
