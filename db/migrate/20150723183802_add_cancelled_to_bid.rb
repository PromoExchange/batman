class AddCancelledToBid < ActiveRecord::Migration
  def change
    add_column :spree_bids, :cancelled_date, :datetime
  end
end
