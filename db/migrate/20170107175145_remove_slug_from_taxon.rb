class RemoveSlugFromTaxon < ActiveRecord::Migration
  def change
    remove_column :spree_taxons, :slug, :string, unique: true
  end
end
