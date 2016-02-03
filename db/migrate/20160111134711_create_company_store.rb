class CreateCompanyStore < ActiveRecord::Migration
  def change
    create_table :spree_company_stores do |t|
      t.string :name
      t.string :slug
      t.integer :supplier_id
      t.integer :buyer_id
    end
  end
end
