class AddHostToCompanyStore < ActiveRecord::Migration
  def change
    add_column :spree_company_stores, :host, :string
  end
end
