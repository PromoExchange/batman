class AddAvgRatingToUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :avg_rating, :decimal, default: 0.0, null: false, precision: 7, scale: 5
    add_column :spree_users, :reviews_count, :integer, default: 0, null: false
  end
end
