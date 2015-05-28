class CreateJoinTableProductsImprintMethods < ActiveRecord::Migration
  def change
    create_join_table :imprint_methods, :products , table_name: 'spree_imprint_methods_products'do |t|
      t.index :imprint_method_id
      t.index :product_id
    end
  end
end
