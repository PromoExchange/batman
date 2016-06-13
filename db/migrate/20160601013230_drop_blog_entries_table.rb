class DropBlogEntriesTable < ActiveRecord::Migration
  def up
    drop_table :spree_blog_entries
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
