class DropMessages < ActiveRecord::Migration
  def change
    drop_table :spree_messages
  end
end
