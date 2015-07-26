class CreateLogoTable < ActiveRecord::Migration
  def change
    create_table :spree_logos do |t|
      t.integer :user_id, null: false
    end
  end
end
