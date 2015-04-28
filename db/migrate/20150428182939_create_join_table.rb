class CreateJoinTable < ActiveRecord::Migration
  def change
    create_join_table :products , :keywords
  end
end
