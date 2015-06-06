class CreateOptionValuesTaxonsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :option_values, :taxons, table_name: 'spree_option_values_taxons' do |t|
      t.index :option_value_id
      t.index :taxon_id
    end
  end
end
