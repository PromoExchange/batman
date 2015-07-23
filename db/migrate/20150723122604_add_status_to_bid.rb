class AddStatusToBid < ActiveRecord::Migration
  def change
    add_column :spree_bids, :status, :string, default: :open
  end
end
