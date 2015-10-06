class AddPaymentClaimedToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :payment_claimed, :boolean, default: false
  end
end
