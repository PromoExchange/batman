class AddRangeToUpcharges < ActiveRecord::Migration
  def change
    add_column :spree_upcharges, :range, :string
    add_column :spree_upcharges, :actual, :string
  end
end
