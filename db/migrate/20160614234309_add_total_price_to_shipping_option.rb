class AddTotalPriceToShippingOption < ActiveRecord::Migration
  def change
    add_column :spree_shipping_options, :shipping_cost, :decimal, null: false, default: 0.0
    add_column :spree_shipping_options, :total_price, :decimal, null: false, default: 0.0
  end
end
