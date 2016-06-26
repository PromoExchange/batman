class AddReferenceToQuote < ActiveRecord::Migration
  def change
    add_column :spree_quotes, :reference, :string, default: ''
  end
end
