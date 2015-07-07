class AddSlugToImprintMethod < ActiveRecord::Migration
  def change
    add_column :spree_imprint_methods, :slug, :string, :unique => true
  end
end
