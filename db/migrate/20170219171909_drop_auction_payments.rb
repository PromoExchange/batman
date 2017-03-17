class DropAuctionPayments < ActiveRecord::Migration
  def change
    drop_table :spree_auction_payments
  end
end
