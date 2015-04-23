class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :title
      t.string :location ,null: false

      t.timestamps null: false
    end
  end
end
