# 20150421135721_change_column_name_to_related
class ChangeColumnNameToRelated < ActiveRecord::Migration
  def change
    rename_column :categories, :parent_id, :related_id
  end
end
