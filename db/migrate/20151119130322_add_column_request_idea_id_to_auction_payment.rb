class AddColumnRequestIdeaIdToAuctionPayment < ActiveRecord::Migration
  def change
    add_column :spree_auction_payments, :request_idea_id, :integer
  end
end
