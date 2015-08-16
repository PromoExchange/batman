class AddFieldsToPrebid < ActiveRecord::Migration
  def change
    add_column :spree_prebids, :eqp, :boolean
    add_column :spree_prebids, :eqp_discount, :decimal
  end
end
