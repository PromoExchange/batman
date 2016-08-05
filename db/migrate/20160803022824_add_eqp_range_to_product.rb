class AddEqpRangeToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :no_eqp_range, :string
  end
end
