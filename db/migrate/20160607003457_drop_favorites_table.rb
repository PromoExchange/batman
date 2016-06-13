class DropFavoritesTable < ActiveRecord::Migration
  def up
    drop_table :spree_favorites
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
