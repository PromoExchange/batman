class AddWorkbookToQuote < ActiveRecord::Migration
  def change
    unless column_exists? :spree_quotes, :workbook
      add_column :spree_quotes, :workbook, :text, default: ''
    end
  end
end
