class CreateSizes < ActiveRecord::Migration
  def change
    create_table :sizes do |t|
      t.string :name, null: false
      t.string :width
      t.string :height
      t.string :depth
      t.string :dia

      t.timestamps null: false
    end
  end
end
