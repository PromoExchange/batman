class AddTypeToUpcharge < ActiveRecord::Migration
  def change
    add_column :spree_upcharges, :type, :string
  end
end
