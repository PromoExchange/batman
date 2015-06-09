class RemoveTaxonFromPrebids < ActiveRecord::Migration
  def change
    remove_column :spree_prebids, :taxon_id
  end
end
