class RemoveTimestampsFromBrand < ActiveRecord::Migration
  def change
    remove_column :brands, :created_at, :string
    remove_column :brands, :updated_at, :string
  end
end
