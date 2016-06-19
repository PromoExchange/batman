class RemoveEqpFromMarkup < ActiveRecord::Migration
  def change
    remove_column :spree_markups, :eqp, :boolean
  end
end
