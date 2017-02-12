class AddQuantitySizesToPurchase < ActiveRecord::Migration
  def change
    add_column :spree_purchases, :quantity_sizes, :string
  end
end
