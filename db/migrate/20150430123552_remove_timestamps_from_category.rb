class RemoveTimestampsFromCategory < ActiveRecord::Migration
  def change
    remove_column :categories, :created_at, :string
    remove_column :categories, :updated_at, :string
  end
end
