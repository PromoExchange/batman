class AddUpchargeIndex < ActiveRecord::Migration
  def change
    add_index :spree_upcharges, :upcharge_type_id
    add_index :spree_upcharges, :related_id
    add_index :spree_upcharges, :imprint_method_id
  end
end
