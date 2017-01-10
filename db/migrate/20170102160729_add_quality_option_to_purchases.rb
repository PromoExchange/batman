class AddQualityOptionToPurchases < ActiveRecord::Migration
  def change
    add_column :spree_purchases, :quality_option, :integer
  end
end
