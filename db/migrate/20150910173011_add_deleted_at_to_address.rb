class AddDeletedAtToAddress < ActiveRecord::Migration
  def change
    add_column :spree_addresses, :deleted_at, :datetime
  end
end
