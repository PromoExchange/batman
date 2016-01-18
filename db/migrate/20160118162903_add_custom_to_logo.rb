class AddCustomToLogo < ActiveRecord::Migration
  def change
    add_column :spree_logos, :custom, :boolean
  end
end
