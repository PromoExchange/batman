class RemoveTimestampsFromLine < ActiveRecord::Migration
  def change
    remove_column :lines, :created_at, :string
    remove_column :lines, :updated_at, :string
  end
end
