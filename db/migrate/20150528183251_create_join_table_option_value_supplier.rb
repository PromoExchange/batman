class CreateJoinTableOptionValueSupplier < ActiveRecord::Migration
  def change
    create_join_table :option_values, :suppliers, table_name: 'spree_option_values_suppliers' do |t|
      t.index :option_value_id
      t.index :supplier_id
    end
  end
end
