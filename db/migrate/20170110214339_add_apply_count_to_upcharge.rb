class AddApplyCountToUpcharge < ActiveRecord::Migration
  def change
    add_column :spree_upcharges, :apply_count, :integer, default: 1
  end
end
