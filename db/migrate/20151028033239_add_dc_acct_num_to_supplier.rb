class AddDcAcctNumToSupplier < ActiveRecord::Migration
  def change
    add_column :spree_suppliers, :dc_acct_num, :string
  end
end
