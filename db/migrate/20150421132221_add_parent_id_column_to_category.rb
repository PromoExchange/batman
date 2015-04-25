# 20150421132221_add_parent_id_column_to_category
class AddParentIdColumnToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :parent_id, :integer
  end
end
