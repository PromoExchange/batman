class AddPurchaseTable < ActiveRecord::Migration
  def change
    create_table :spree_purchases do |t|
      t.integer :quantity, null: false
      t.integer :product_id, null: false
      t.integer :logo_id, null: false
      t.integer :imprint_method_id, null: false
      t.integer :main_color_id, null: false
      t.integer :buyer_id, null: false
      t.integer :order_id
      t.integer :shipping_option, null: false
    end
  end
end
