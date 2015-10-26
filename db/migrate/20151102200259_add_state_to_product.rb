class AddStateToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :state, :string
  end
end
