class AddCodeToPrice < ActiveRecord::Migration
  def change
    add_column :prices, :code, :string, :default 'X'
  end
end
