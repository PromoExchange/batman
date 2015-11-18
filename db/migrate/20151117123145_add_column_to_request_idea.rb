class AddColumnToRequestIdea < ActiveRecord::Migration
  def change
    add_column :spree_request_ideas, :sku, :string
    remove_column :spree_request_ideas, :product_id, :integer
  end
end
