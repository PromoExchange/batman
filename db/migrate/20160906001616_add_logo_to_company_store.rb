class AddLogoToCompanyStore < ActiveRecord::Migration
  def change
    add_attachment :spree_company_stores, :logo
  end
end
