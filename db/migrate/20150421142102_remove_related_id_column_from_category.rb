# 20150421142102_remove_related_id_column_from_category
class RemoveRelatedIdColumnFromCategory < ActiveRecord::Migration
  def change
    remove_column :categories, :related_id
  end
end
