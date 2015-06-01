# This migration comes from spree_px_auction (originally 20150601182959)
# This migration comes from spree_px_auction (originally 20150601182959)
class AddOrderToBid < ActiveRecord::Migration
  def change
    add_column :spree_bids, :order_id, :integer
  end
end
