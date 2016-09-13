class AddReferenceToPurchase < ActiveRecord::Migration
  def change
    add_column :spree_purchases, :reference, :string, default: ""
  end
end
