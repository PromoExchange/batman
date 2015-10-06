class AddProofFeedbackToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :proof_feedback, :string
  end
end
