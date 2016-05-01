class AddFieldsToBid < ActiveRecord::Migration
  def change
    add_column :spree_bids, :service_name, :string, default: ''
    add_column :spree_bids, :shipping_cost, :decimal, default: 0.0
    add_column :spree_bids, :delivery_days, :integer, default: 5
  end
end
