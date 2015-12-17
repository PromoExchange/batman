class AddPaidColumnToRequestIdea < ActiveRecord::Migration
  def change
    add_column :spree_request_ideas, :paid, :boolean, default: :false
  end
end
