class CreateJoinTableProductMediaReference < ActiveRecord::Migration
  def change
    create_join_table :products, :media_references
  end
end
