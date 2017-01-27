class AddQualityNoteToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :quality_note, :string
  end
end
