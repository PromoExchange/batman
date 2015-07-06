class AddIdToImprintMethodProduct < ActiveRecord::Migration
  def change
    add_column :spree_imprint_methods_products, :id, :primary_key
  end
end
