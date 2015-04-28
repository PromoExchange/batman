class CreateJoinTableProductSize < ActiveRecord::Migration
  def change
    create_join_table :products, :sizes
  end
end
