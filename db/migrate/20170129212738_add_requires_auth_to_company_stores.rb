class AddRequiresAuthToCompanyStores < ActiveRecord::Migration
  def change
    add_column :spree_company_stores, :requires_auth, :boolean, default: false
  end
end
