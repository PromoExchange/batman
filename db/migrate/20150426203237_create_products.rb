class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :includes
      t.string :features
      t.integer :packsize
      t.string :packweight
      t.string :unit_measure
      t.string :leadtime
      t.string :rushtime
      t.string :info
      t.timestamps null: false
    end
  end
end
