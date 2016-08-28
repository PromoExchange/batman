class AddReferenceToQuote < ActiveRecord::Migration
  def change
    unless column_exists? :spree_quotes, :reference
      add_column :spree_quotes, :reference, :string, default: ''
    end
  end
end
