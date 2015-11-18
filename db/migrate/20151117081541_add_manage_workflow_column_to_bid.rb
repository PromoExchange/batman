class AddManageWorkflowColumnToBid < ActiveRecord::Migration
  def change
    add_column :spree_bids, :manage_workflow, :boolean, default: :false
  end
end
