# 20150425125013_create_colors
class CreateColors < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
