class AddCancelledDateToAuction < ActiveRecord::Migration
  def change
    add_column :spree_auctions, :cancelled_date, :datetime
  end
end
