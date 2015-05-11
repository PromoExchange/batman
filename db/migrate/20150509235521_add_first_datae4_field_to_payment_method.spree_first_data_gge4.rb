# This migration comes from spree_first_data_gge4 (originally 20150507111350)
class AddFirstDatae4FieldToPaymentMethod < ActiveRecord::Migration
  def change
    add_column :spree_payment_methods, :title_e4, :string
    add_column :spree_payment_methods, :payment_page_login_e4, :string
    add_column :spree_payment_methods, :transaction_key_e4, :string
    add_column :spree_payment_methods, :return_url_e4, :string
    add_column :spree_payment_methods, :transaction_type_e4, :string
  end
end
