class AddIndicesToTables < ActiveRecord::Migration
  def change
    # Join tables
    add_index :category_related, :category_id
    add_index :category_related, :related_id

    add_index :colors_products, :product_id
    add_index :colors_products, :color_id

    add_index :keywords_products, :product_id
    add_index :keywords_products, :keyword_id

    add_index :lines_products, :product_id
    add_index :lines_products, :line_id

    add_index :materials_products, :product_id
    add_index :materials_products, :material_id

    add_index :media_references_products, :product_id
    add_index :media_references_products, :media_reference_id

    add_index :prices_products, :product_id
    add_index :prices_products, :price_id

    add_index :products_sizes, :product_id
    add_index :products_sizes, :size_id

    add_index :imagetypes, :product_id
    add_index :imagetypes, :image_id

    # Foreign Keys
    add_index :products, :supplier_id

    add_index :lines, :brand_id
  end
end
