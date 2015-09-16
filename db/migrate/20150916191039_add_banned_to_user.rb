class AddBannedToUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :banned, :boolean, default: false
  end
end
