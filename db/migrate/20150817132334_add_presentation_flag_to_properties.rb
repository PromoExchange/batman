class AddPresentationFlagToProperties < ActiveRecord::Migration
  def change
    add_column :spree_properties, :do_not_display, :boolean, default: false
  end
end
