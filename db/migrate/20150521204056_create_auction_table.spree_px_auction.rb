# This migration comes from spree_px_auction (originally 20150512174605)
class CreateAuctionTable < ActiveRecord::Migration
  def change
    create_table :spree_auctions do |t|
      t.integer :product_id, null: false
      t.integer :seller_id, null: false
      t.integer :bidder_id, null: false
      t.string :descripiton
      t.datetime :started
      t.datetime :ended
      t.decimal :bid

      t.timestamps null: false
    end
  end
end
