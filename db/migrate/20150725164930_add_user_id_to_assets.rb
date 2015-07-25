class AddUserIdToAssets < ActiveRecord::Migration
  def change
    add_column :spree_assets, :user_id, :integer
  end
end
