class AddImprintMethodToPmsColorsSuppliers < ActiveRecord::Migration
  def change
    add_column :spree_pms_colors_suppliers, :imprint_method_id, :integer
  end
end
