class AddFixedToCarton < ActiveRecord::Migration
  def change
    add_column :spree_cartons, :fixed_price, :decimal
  end
end
