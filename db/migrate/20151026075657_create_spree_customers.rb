class CreateSpreeCustomers < ActiveRecord::Migration
  def change
    create_table :spree_customers do |t|
      t.integer :user_id
      t.string :token
      t.string :brand
      t.string :last_4_digits

      t.timestamps null: false
    end
  end
end
