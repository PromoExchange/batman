class RemoveTimestampsFromColor < ActiveRecord::Migration
  def change
    remove_column :colors, :created_at, :string
    remove_column :colors, :updated_at, :string
  end
end
