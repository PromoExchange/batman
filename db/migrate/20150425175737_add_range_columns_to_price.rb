# 20150425175737_add_range_columns_to_price
class AddRangeColumnsToPrice < ActiveRecord::Migration
  def change
    add_column :prices, :lower, :string
    add_column :prices, :upper, :string
  end
end
