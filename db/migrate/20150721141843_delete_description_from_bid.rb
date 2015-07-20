class DeleteDescriptionFromBid < ActiveRecord::Migration
  def change
    remove_column :spree_bids, :description
  end
end
