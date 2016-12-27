class AddSlugToTaxons < ActiveRecord::Migration
  def change
    add_column :spree_taxons, :slug, :string, unique: true
  end
end
