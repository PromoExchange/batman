class DeleteShippingOption < ActiveRecord::Migration
  def change
    drop_table :spree_shipping_options
  end
end
