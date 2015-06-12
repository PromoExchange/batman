class RemoveBidColumnFromBidTable < ActiveRecord::Migration
  def change
    remove_column :spree_bids, :bid
  end
end
