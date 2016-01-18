class CreatePreconfigure < ActiveRecord::Migration
  def change
    create_table :spree_preconfigures do |t|
      t.integer :product_id, null: false
      t.integer :buyer_id, null: false
      t.integer :imprint_method_id, null: false
      t.integer :main_color_id, null: false
      t.integer :logo_id, null: false
      t.string :custom_pms_colors
    end
  end
end
