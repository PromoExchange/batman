class ChangeColumnNameToRelated < ActiveRecord::Migration
  def change
    rename_column :categories, :parent_id, :related_id
  end
end
