class RemoveRelatedIdColumnFromCategory < ActiveRecord::Migration
  def change
    remove_column :categories, :related_id
  end
end
