class RemoveTimestampsFromMediaReference < ActiveRecord::Migration
  def change
    remove_column :media_references, :created_at, :string
    remove_column :media_references, :updated_at, :string
  end
end
