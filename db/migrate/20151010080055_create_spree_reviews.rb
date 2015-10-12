class CreateSpreeReviews < ActiveRecord::Migration
  def change
    create_table :spree_reviews do |t|
      t.integer :auction_id
      t.integer :user_id
      t.integer :rating
      t.text    :review
      t.string  :ip_address
      t.boolean :approved, default: true
      t.timestamps null: false
    end
  end
end