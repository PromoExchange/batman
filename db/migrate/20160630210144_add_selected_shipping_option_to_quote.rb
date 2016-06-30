class AddSelectedShippingOptionToQuote < ActiveRecord::Migration
  def change
    add_column :spree_quotes, :selected_shipping_option, :integer, default: Spree::ShippingOption::OPTION[:ups_ground]
  end
end
