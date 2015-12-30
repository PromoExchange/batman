class AddCodeToVolumePrice < ActiveRecord::Migration
  def change
    add_column :spree_volume_prices, :price_code, :string
  end
end
