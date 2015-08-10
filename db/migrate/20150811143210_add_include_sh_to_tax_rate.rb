class AddIncludeShToTaxRate < ActiveRecord::Migration
  def change
    add_column :spree_tax_rates, :include_in_sandh, :boolean
  end
end
