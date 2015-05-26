# This migration comes from spree_px_auction (originally 20150525174034)
class RequiredByToSpreeAuctions < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :required_by, :datetime
  end
end
