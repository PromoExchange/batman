class CreateSpreeRequestIdeas < ActiveRecord::Migration
  def change
    create_table :spree_request_ideas do |t|
      t.integer :product_request_id, null: false
      t.integer :product_id, null: false
      t.decimal :cost, default: 0.0, null: false
      t.string :state

      t.timestamps null: false
    end
  end
end
