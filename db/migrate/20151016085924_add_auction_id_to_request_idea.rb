class AddAuctionIdToRequestIdea < ActiveRecord::Migration
  def change
    add_column :spree_request_ideas, :auction_id, :integer
  end
end
