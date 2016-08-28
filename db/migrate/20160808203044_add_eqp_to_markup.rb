class AddEqpToMarkup < ActiveRecord::Migration
  def change
    unless column_exists? :spree_quotes, :eqp
      add_column :spree_markups, :eqp, :boolean, default: false
    end
  end
end
