class AddWorkbookToQuote < ActiveRecord::Migration
  def change
    add_column :spree_quotes, :workbook, :text, default: ''
  end
end
