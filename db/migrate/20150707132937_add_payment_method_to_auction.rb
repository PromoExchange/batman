class AddPaymentMethodToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :payment_method, :string, null: false
  end
end
