class RemoveTimestampsFromKeyword < ActiveRecord::Migration
  def change
    remove_column :keywords, :created_at, :string
    remove_column :keywords, :updated_at, :string
  end
end
