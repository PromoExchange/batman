class RemoveImprintFromQuote < ActiveRecord::Migration
  def change
    remove_column :spree_quotes, :imprint_method_id, :integer
  end
end
