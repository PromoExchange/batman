class RemoveFieldsFromShippingOption < ActiveRecord::Migration
  def change
    remove_column :spree_shipping_options, :delta, :decimal
    remove_column :spree_shipping_options, :total_price, :decimal
  end
end
