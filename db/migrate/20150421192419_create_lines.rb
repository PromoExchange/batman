# 20150421192419_create_lines
class CreateLines < ActiveRecord::Migration
  def change
    create_table :lines do |t|
      t.string :name, null: false
      t.integer :brand_id, null: false
      t.timestamps null: false
    end
  end
end
