class AddDefaultForProductionTime < ActiveRecord::Migration
  def change
    change_column :spree_products, :production_time, :integer, default: 7
  end
end
