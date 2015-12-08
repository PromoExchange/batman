class CreateOptionMapping < ActiveRecord::Migration
  def change
    create_table :spree_option_mappings do |t|
      t.string :dc_acct_num
      t.string :dc_name
      t.string :px_name
      t.boolean :do_not_save, :default => true
    end
  end
end
