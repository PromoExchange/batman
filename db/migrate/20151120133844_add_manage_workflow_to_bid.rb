class AddManageWorkflowToBid < ActiveRecord::Migration
  def change
    unless column_exists? :spree_bids, :manage_workflow
      add_column :spree_bids, :manage_workflow, :boolean, default: :false
    end
  end
end
