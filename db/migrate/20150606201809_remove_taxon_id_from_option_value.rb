class RemoveTaxonIdFromOptionValue < ActiveRecord::Migration
  def change
    remove_column :spree_option_values, :taxon_id
  end
end
