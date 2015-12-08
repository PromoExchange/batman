class AddShippingAddressToSupplier < ActiveRecord::Migration
  def change
    add_column :spree_suppliers, :shipping_address_id, :integer
    rename_column :spree_suppliers, :address_id, :billing_address_id
  end
end
