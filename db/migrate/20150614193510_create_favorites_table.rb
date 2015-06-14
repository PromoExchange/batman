class CreateFavoritesTable < ActiveRecord::Migration
  def change
    create_table :spree_favorites do |t|
      t.integer :product_id, null: false
      t.integer :buyer_id, null: false
    end
    add_index :spree_favorites, :buyer_id
  end
end
