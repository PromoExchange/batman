# This migration comes from spree_static_content (originally 20090814113100)
class AddVisibleToPages < ActiveRecord::Migration
  class Page < ActiveRecord::Base
  end

  def self.up
    add_column :spree_pages, :visible, :boolean
    if Page.table_exists?
      Page.update_all :visible => true
    else
      if defined?(Spree::Page) == 'constant' && Spree::Page.class == Class
        Spree::Page.update_all :visible => true
      end
    end
  end

  def self.down
    remove_column :spree_pages, :visible
  end
end
