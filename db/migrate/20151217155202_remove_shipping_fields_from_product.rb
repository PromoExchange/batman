class RemoveShippingFieldsFromProduct < ActiveRecord::Migration
  def change
    remove_column :spree_products, :shipping_quantity, :string
    remove_column :spree_products, :shipping_weight, :string
    remove_column :spree_products, :shipping_dimensions, :string
    remove_column :spree_products, :originating_zip, :string
  end
end
