class CreateUpchargeTable < ActiveRecord::Migration
  def change
    create_table :spree_upcharges do |t|
      t.integer :upcharge_type_id, null: false
      t.string :related_type, null: false
      t.integer :related_id, null: false
      t.string :value, null: false
    end
  end
end
