class AddColumnsToShippingOption < ActiveRecord::Migration
  def change
    add_column :spree_shipping_options, :delivery_date, :datetime, null: false
    add_column :spree_shipping_options, :delivery_days, :integer, null: false
  end
end
