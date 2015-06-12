class CreateTableOptionValueProduct < ActiveRecord::Migration
  def change
    create_table :spree_option_values_products do |t|
      t.string  :type, null: false
      t.integer :option_value_id, null: false
      t.integer :product_id, null: false
      t.string :value_type
      t.string :value
    end
    add_index :spree_option_values_products, :option_value_id
    add_index :spree_option_values_products, :product_id
    add_index :spree_option_values_products, :type
  end
end
