class AddPerToCarton < ActiveRecord::Migration
  def change
    add_column :spree_cartons, :per_item, :boolean, default: false
  end
end
