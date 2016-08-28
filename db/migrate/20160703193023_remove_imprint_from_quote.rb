class RemoveImprintFromQuote < ActiveRecord::Migration
  def change
    if column_exists? :spree_quotes, :imprint_method_id
      remove_column :spree_quotes, :imprint_method_id, :integer
    end
  end
end
