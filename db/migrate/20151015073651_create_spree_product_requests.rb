class CreateSpreeProductRequests < ActiveRecord::Migration
  def change
    create_table :spree_product_requests do |t|
      t.integer :buyer_id, null: false
      t.string :request
      t.string :state

      t.timestamps null: false
    end
  end
end
