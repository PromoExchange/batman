class CreateSpreeAuctionSizes < ActiveRecord::Migration
  def change
    create_table :spree_auction_sizes do |t|
      t.integer :auction_id
      t.string :product_size
      
      t.timestamps null: false
    end
  end
end
