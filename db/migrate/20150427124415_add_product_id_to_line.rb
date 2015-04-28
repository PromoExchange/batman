class AddProductIdToLine < ActiveRecord::Migration
  def change
    add_column :lines, :product_id, :integer, :null => false
  end
end
