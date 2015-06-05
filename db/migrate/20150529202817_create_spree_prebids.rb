# This migration comes from spree_px_auction (originally 20150529171933)
class CreateSpreePrebids < ActiveRecord::Migration
  def change
    create_table :spree_prebids do |t|
      t.integer :taxon_id, null: false
      t.integer :seller_id, null: false
      t.string :description

      t.timestamps null: false
    end
  end
end
