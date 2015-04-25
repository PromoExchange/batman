# 20150423154442_create_imagetypes
class CreateImagetypes < ActiveRecord::Migration
  def change
    create_table :imagetypes do |t|
      t.integer :image_id, null: false
      t.integer :product_id, null: false
      t.string :sizetype, null: false
      t.timestamps null: false
    end
  end
end
