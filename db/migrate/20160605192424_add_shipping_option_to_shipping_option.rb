class AddShippingOptionToShippingOption < ActiveRecord::Migration
  def change
    add_column :spree_shipping_options, :shipping_option, :integer, null: false
  end
end
