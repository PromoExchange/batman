class AddImprintMethodToUpcharge < ActiveRecord::Migration
  def change
    add_column :spree_upcharges, :imprint_method_id, :integer
  end
end
