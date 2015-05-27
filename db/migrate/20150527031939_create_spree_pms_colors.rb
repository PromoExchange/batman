class CreateSpreePmsColors < ActiveRecord::Migration
  def change
    create_table :spree_pms_colors do |t|
      t.string :name, null: false
      t.string :pantone, null: false
      t.string :textile
      t.string :hex
    end
  end
end
