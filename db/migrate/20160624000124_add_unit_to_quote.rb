class AddUnitToQuote < ActiveRecord::Migration
  def change
    add_column :spree_quotes, :unit_price, :decimal, default: 0.0
  end
end
