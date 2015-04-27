class RemoveProductIdFromLine < ActiveRecord::Migration
  def up
    remove_column :lines, :product_id
  end

  def down
    add_column :lines, :product_id, :integer
  end
end
