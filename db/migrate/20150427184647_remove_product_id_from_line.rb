class RemoveProductIdFromLine < ActiveRecord::Migration
  def change
    remove_column :lines, :product_id
  end
end
