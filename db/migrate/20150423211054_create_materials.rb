class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.string :material, null: false
      # t.timestamps null: false
    end
  end
end
