class AddPaymentTypeToBid < ActiveRecord::Migration
  def change
    add_column :spree_bids, :payment_type, :string
  end
end
