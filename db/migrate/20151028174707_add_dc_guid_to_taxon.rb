class AddDcGuidToTaxon < ActiveRecord::Migration
  def change
    add_column :spree_taxons, :dc_category_guid, :string
  end
end
