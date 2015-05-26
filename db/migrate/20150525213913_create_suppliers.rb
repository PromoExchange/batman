class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :spree_suppliers do |t|
      t.integer :address_id
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end
end
