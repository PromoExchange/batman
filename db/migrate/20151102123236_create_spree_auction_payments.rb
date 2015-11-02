class CreateSpreeAuctionPayments < ActiveRecord::Migration
  def change
    create_table :spree_auction_payments do |t|
      t.integer :bid_id
      t.string :charge_id
      t.string :status

      t.timestamps null: false
    end
  end
end
