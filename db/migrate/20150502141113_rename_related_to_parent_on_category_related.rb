class RenameRelatedToParentOnCategoryRelated < ActiveRecord::Migration
  def change
    rename_column :category_related, :related_id, :parent_id
  end
end
