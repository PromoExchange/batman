class AddProductIdToMessage < ActiveRecord::Migration
  def change
    add_column :spree_messages, :product_id, :integer, null: false
  end
end
