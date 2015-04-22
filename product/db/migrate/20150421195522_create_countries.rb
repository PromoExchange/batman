class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :code_2, null: false
      t.string :code_3, null: false
      t.string :short_name, null: false
      t.integer :code_numeric, null: false
      t.timestamps null: false
    end
  end
end
