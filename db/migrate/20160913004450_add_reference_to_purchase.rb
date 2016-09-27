class AddReferenceToPurchase < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:spree_purchases, :reference)
      add_column :spree_purchases, :reference, :string, default: ""
    end
  end
end
