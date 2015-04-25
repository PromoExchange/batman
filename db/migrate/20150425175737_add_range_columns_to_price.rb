class AddRangeColumnsToPrice < ActiveRecord::Migration
  def change
    add_column :prices, :lower, :string
    add_column :prices, :upper, :string
  end
end
