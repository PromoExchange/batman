class AddCustomProductToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :custom_product, :boolean
  end
end
