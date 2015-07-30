class AddAsiNumberToUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :asi_number, :string
  end
end
