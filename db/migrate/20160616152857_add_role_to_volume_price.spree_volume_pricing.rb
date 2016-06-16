# This migration comes from spree_volume_pricing (originally 20150513200904)
class AddRoleToVolumePrice < ActiveRecord::Migration
  def change
    add_column :spree_volume_prices, :role_id, :integer
  end
end
