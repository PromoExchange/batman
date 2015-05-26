class CreateJoinTableProductsImprintMethods < ActiveRecord::Migration
  def change
    create_table :spree_imprint_methods_products do |t|
      t.integer :product_id, null: false
      t.integer :imprint_method_id, null: false
    end

    add_index(:spree_imprint_methods_products,
              [:product_id, :imprint_method_id],
              name: 'spree_imprint_product_idx')
  end
end
