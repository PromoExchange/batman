class AddTypeToCompanyStore < ActiveRecord::Migration
  def change
    add_column :spree_company_stores, :store_type, :integer, default: 0
  end
end
