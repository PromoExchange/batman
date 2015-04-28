class ProductLine < ActiveRecord::Migration
  def change
    create_join_table :products, :lines
  end
end
