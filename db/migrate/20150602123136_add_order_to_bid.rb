class AddOrderToBid < ActiveRecord::Migration
  def change
    add_column :spree_bids, :order_id, :integer
  end
end
