class AddSelectedShippingOptionToQuote < ActiveRecord::Migration
  def change
    unless column_exists? :spree_quotes, :selected_shipping_option
      add_column :spree_quotes, :selected_shipping_option, :integer, default: :ups_ground
    end
  end
end
