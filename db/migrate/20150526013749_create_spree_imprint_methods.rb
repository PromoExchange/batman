class CreateSpreeImprintMethods < ActiveRecord::Migration
  def change
    create_table :spree_imprint_methods do |t|
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
