class AddCompanyStoreToSupplier < ActiveRecord::Migration
  def change
    add_column :spree_suppliers, :company_store, :boolean, default: false
  end
end
