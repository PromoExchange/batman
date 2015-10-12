class AddShippingAgentToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :shipping_agent, :string, default: 'ups'
  end
end
