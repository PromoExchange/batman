class AddUseridToTaxRate < ActiveRecord::Migration
  def change
    add_column :spree_tax_rates, :user_id, :integer
  end
end
