class CreateJoinTablePmsSupplier < ActiveRecord::Migration
  def change
    create_join_table :pms_colors, :suppliers , table_name: 'spree_pms_colors_suppliers' do |t|
      t.index :supplier_id
      t.index :pms_color_id
    end
  end
end
