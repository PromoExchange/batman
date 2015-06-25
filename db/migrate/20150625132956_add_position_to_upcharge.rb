class AddPositionToUpcharge < ActiveRecord::Migration
  def change
    add_column :spree_upcharges, :position, :integer
  end
end
