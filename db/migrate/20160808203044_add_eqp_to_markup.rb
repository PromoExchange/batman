class AddEqpToMarkup < ActiveRecord::Migration
  def change
    add_column :spree_markups, :eqp, :boolean, default: false
  end
end
