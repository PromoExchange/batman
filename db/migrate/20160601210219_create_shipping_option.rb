class CreateShippingOption < ActiveRecord::Migration
  def change
    create_table :spree_shipping_options do |t|
      t.string :name, null: false
      t.integer :bid_id, null: false
      t.decimal :delta, null: false
    end

    add_index :spree_shipping_options, [:bid_id]
  end
end
