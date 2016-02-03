class CreatePriceCache < ActiveRecord::Migration
  def change
    create_table :spree_price_caches do |t|
      t.integer :product_id
      t.string :range
      t.decimal :lowest_price
      t.integer :position
      t.timestamps null: false
    end
  end
end
