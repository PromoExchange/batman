class AddFieldsToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :max_retail, :decimal
    add_column :spree_products, :min_qty, :integer
    add_column :spree_products, :min_retail, :decimal
    add_column :spree_products, :production_time, :integer
    add_column :spree_products, :rush_available, :boolean
    add_column :spree_products, :supplier_display_name, :string
    add_column :spree_products, :supplier_display_num, :string
    add_column :spree_products, :supplier_item_num, :string
    add_column :spree_products, :supplier_item_guid, :string
    add_column :spree_products, :country_name, :string
    add_column :spree_products, :dc_increment, :string
    add_column :spree_products, :last_update_date, :datetime
    add_column :spree_products, :size, :datetime
    add_column :spree_products, :weight, :datetime
  end
end
