class SetPrebidDefaults < ActiveRecord::Migration
  def change
    change_column :spree_prebids, :markup, :decimal, :default => 0.0
    change_column :spree_prebids, :eqp, :boolean, :default => false
    change_column :spree_prebids, :eqp_discount, :decimal, :default => 0.0
  end
end
