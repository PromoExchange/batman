class AddPrebidToBid < ActiveRecord::Migration
  def change
    add_column :spree_bids, :prebid_id, :integer
  end
end
