class RemoveStatusFromBid < ActiveRecord::Migration
  def change
    remove_column :spree_bids, :status
  end
end
