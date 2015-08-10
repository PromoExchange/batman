class AddMarkupToPrebid < ActiveRecord::Migration
  def change
    add_column :spree_prebids, :markup, :decimal
  end
end
