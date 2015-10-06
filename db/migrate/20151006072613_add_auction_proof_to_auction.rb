class AddAuctionProofToAuction < ActiveRecord::Migration
  def change
    add_attachment :spree_auctions, :proof_file
  end
end
