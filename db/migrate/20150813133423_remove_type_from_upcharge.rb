class RemoveTypeFromUpcharge < ActiveRecord::Migration
  def change
    remove_column :spree_upcharges, :related_type
  end
end
