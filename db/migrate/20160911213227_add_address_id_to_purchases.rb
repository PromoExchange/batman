class AddAddressIdToPurchases < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:spree_purchases, :address_id)
      add_column :spree_purchases, :address_id, :integer, null: false
    end
  end
end
