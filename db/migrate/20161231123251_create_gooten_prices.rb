class CreateGootenPrices < ActiveRecord::Migration
  def change
    create_table :spree_gooten_prices do |t|
      t.integer :company_store_id, null: false
      t.integer :product_id, null: false
      t.integer :quantity, null: false
      t.decimal :price, null: false, default: 0.0
    end
  end
end
