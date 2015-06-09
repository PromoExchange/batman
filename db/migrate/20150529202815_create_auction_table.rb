class CreateAuctionTable < ActiveRecord::Migration
  def change
    create_table :spree_auctions do |t|
      t.integer :product_id, null: false
      t.integer :buyer_id, null: false
      t.integer :quantity, null: false
      t.string :description
      t.datetime :started
      t.datetime :ended

      t.timestamps null: false
    end
  end
end
