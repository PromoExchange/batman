class DropPages < ActiveRecord::Migration
  def change
    drop_table :spree_pages
    drop_table :spree_pages_stores
  end
end
