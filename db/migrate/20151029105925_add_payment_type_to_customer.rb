class AddPaymentTypeToCustomer < ActiveRecord::Migration
  def change
    add_column :spree_customers, :payment_type, :string
    add_column :spree_customers, :status, :string
  end
end
