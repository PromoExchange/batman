# 20150425161124_create_media_references
class CreateMediaReferences < ActiveRecord::Migration
  def change
    create_table :media_references do |t|
      t.string :name, null: false
      t.string :location, null: false
      t.string :reference, null: false
      t.timestamps null: false
    end
  end
end
