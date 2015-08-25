class JoinTableAuctionUser < ActiveRecord::Migration
  def change
    create_join_table :auctions, :users, table_name: 'spree_auctions_users'  do |t|
      t.index :auction_id
      t.index :user_id
    end
  end
end
