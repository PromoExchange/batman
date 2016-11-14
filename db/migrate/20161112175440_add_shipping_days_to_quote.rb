class AddShippingDaysToQuote < ActiveRecord::Migration
  def change
    add_column :spree_quotes, :shipping_days, :integer, default: 5, null: false
  end
end
