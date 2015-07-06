class ColorProduct < ActiveRecord::Migration
  def change
    create_table :spree_color_products do |t|
      t.integer :product_id, null: false
      t.string :color, null: false
    end
    add_index :spree_color_products, :product_id
  end
end
