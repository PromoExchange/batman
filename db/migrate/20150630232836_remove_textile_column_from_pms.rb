class RemoveTextileColumnFromPms < ActiveRecord::Migration
  def change
    remove_column :spree_pms_colors, :textile
  end
end
