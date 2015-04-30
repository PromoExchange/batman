class RemoveTimestampsFromSize < ActiveRecord::Migration
  def change
    remove_column :sizes, :created_at, :string
    remove_column :sizes, :updated_at, :string
  end
end
