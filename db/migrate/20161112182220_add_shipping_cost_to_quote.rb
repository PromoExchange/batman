class AddShippingCostToQuote < ActiveRecord::Migration
  def change
    add_column :spree_quotes, :shipping_cost, :decimal
  end
end
