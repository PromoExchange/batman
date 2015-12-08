class ChangeRatingTypeOfReview < ActiveRecord::Migration
  def change
    change_column :spree_reviews, :rating,  :float, :default => 0.0
  end
end
