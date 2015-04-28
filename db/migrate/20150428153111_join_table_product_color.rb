class JoinTableProductColor < ActiveRecord::Migration
  def change
    create_join_table :products, :colors
  end
end
