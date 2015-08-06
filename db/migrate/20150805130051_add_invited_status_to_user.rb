class AddInvitedStatusToUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :invited, :boolean, default: false
  end
end
