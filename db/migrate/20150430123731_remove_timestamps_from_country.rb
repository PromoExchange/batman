class RemoveTimestampsFromCountry < ActiveRecord::Migration
  def change
    remove_column :countries, :created_at, :string
    remove_column :countries, :updated_at, :string
  end
end
