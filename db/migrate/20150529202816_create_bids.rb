class CreateBids < ActiveRecord::Migration
  def change
    create_table :spree_bids do |t|
      t.integer :auction_id, null: false
      t.integer :seller_id, null: false
      t.string :description
      t.decimal :bid, precision: 8, scale: 2, null: false

      t.timestamps null: false
    end
  end
end
