# 20150421193713_create_keywords
class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :word, null: false
      t.timestamps null: false
    end
  end
end
