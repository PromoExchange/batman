class CategoryRelated < ActiveRecord::Migration
  def change
    create_table :category_related do |t|
      t.integer :category_id, null: false
      t.integer :related_id, null: false
    end
  end
end
