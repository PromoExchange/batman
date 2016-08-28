class RemoveEqpFromMarkup < ActiveRecord::Migration
  def change
    if column_exists? :spree_markups, :eqp
      remove_column :spree_markups, :eqp, :boolean
    end
  end
end
