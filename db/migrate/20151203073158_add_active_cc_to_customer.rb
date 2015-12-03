class AddActiveCcToCustomer < ActiveRecord::Migration
  def change
    add_column :spree_customers, :active_cc, :boolean, default: false
  end
end
