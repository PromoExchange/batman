class CreateMessages < ActiveRecord::Migration
  def change
    create_table :spree_messages do |t|
      t.integer :owner_id, null: false
      t.integer :from_id, null: false
      t.integer :to_id, null: false
      t.string :status
      t.string :subject
      t.string :body

      t.timestamps null: false
    end
  end
end
