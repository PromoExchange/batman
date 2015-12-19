class AddOriginatingZipToCarton < ActiveRecord::Migration
  def change
    add_column :spree_cartons, :originating_zip, :string, default: ''
  end
end
