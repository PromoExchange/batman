class AddUnitToQuote < ActiveRecord::Migration
  def change
    unless column_exists? :spree_quotes, :unit_price
      add_column :spree_quotes, :unit_price, :decimal, default: 0.0
    end
  end
end
