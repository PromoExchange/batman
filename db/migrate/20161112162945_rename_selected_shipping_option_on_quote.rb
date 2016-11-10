class RenameSelectedShippingOptionOnQuote < ActiveRecord::Migration
  def change
    rename_column :spree_quotes, :selected_shipping_option, :shipping_option
  end
end
