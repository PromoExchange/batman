class AddQuoteToShippingOption < ActiveRecord::Migration
  def change
    Spree::ShippingOption.destroy_all
    remove_column :spree_shipping_options, :bid_id, :integer, null: false
    add_column :spree_shipping_options, :quote_id, :integer, null: false
  end
end
