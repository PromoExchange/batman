class CreateJoinTableProductMaterials < ActiveRecord::Migration
  def change
    create_join_table :products, :materials
  end
end
