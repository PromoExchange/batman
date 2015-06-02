# This migration comes from spree_px_auction (originally 20150601183726)
# This migration comes from spree_px_auction (originally 20150601183726)
class AddPrebidToBid < ActiveRecord::Migration
  def change
    add_column :spree_bids, :prebid_id, :integer
  end
end
