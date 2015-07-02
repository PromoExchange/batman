class AddIdToPmsColorSupplier < ActiveRecord::Migration
  def change
    add_column :spree_pms_colors_suppliers, :id, :primary_key
  end
end
