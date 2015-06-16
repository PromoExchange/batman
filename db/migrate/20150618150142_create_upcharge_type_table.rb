class CreateUpchargeTypeTable < ActiveRecord::Migration
  def change
    create_table :spree_upcharge_types do |t|
      t.string :name, null: false
    end
  end
end
