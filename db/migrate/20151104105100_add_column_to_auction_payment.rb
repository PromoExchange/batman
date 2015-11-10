class AddColumnToAuctionPayment < ActiveRecord::Migration
  def change
    add_column :spree_auction_payments, :failure_code, :string
    add_column :spree_auction_payments, :failure_message, :string
  end
end
