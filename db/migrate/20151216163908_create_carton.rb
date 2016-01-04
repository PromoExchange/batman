class CreateCarton < ActiveRecord::Migration
  def change
    create_table :spree_cartons do |t|
      t.integer :product_id
      t.string :width, default: ''
      t.string :length, default: ''
      t.string :height, default: ''
      t.string :weight, default: ''
      t.integer :quantity, default: 0
    end
  end
end
