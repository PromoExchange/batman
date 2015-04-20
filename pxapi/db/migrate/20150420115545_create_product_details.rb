class CreateProductDetails < ActiveRecord::Migration
  def change
    create_table :product_details do |t|
      t.string :name
      t.string :desc
      t.string :imageurl
      t.float :price
      t.string :overview
      t.string :detail
      t.string :production_time
      t.string :imprint_lines
      t.timestamps null: false
    end
  end
end
