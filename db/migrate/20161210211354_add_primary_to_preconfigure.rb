class AddPrimaryToPreconfigure < ActiveRecord::Migration
  def change
    add_column :spree_preconfigures, :primary, :boolean, default: true, null: false
  end
end
