class AddProductIdToPrebid < ActiveRecord::Migration
  def change
    add_column :spree_prebids, :product_id, :integer, null: false
  end
end
