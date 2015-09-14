class AddStateToBid < ActiveRecord::Migration
  def change
    add_column :spree_bids, :state, :string
  end
end
