class AddUpchargeToCarton < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:spree_cartons, :upcharge)
      add_column :spree_cartons, :upcharge, :decimal
    end
  end
end
