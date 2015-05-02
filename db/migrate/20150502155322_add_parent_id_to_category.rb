class AddParentIdToCategory < ActiveRecord::Migration
  def change
    add_column(:categories, :parent_id, :integer, null: false)
  end
end
