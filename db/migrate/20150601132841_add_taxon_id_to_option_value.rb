class AddTaxonIdToOptionValue < ActiveRecord::Migration
  def change
    add_column :spree_option_values, :taxon_id, :integer
  end
end
