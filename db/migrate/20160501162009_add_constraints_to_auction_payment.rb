class AddConstraintsToAuctionPayment < ActiveRecord::Migration
  def change
    change_column :spree_auction_payments, :bid_id, :integer, null: false
  end
end
