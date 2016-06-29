class AddQuoteToPmsColor < ActiveRecord::Migration
  def change
    add_column :spree_pms_colors, :quote_id, :integer
  end
end
