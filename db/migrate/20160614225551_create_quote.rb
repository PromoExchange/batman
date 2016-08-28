class CreateQuote < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.table_exists? 'spree_quotes'
      create_table :spree_quotes do |t|
        t.integer :quantity, null: false
        t.integer :product_id, null: false
        t.integer :quantity, null: false
        t.integer :imprint_method_id, null: false
        t.integer :shipping_address_id, null: false
        t.integer :main_color_id, null: false
        t.string  :custom_pms_colors
      end
    end
  end
end
