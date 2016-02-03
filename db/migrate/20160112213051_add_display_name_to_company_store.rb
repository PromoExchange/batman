class AddDisplayNameToCompanyStore < ActiveRecord::Migration
  def change
    add_column :spree_company_stores, :display_name, :string
  end
end
