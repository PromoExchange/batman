class CreateJoinTableProductPrice < ActiveRecord::Migration
  def change
    create_join_table :products, :prices
  end
end
