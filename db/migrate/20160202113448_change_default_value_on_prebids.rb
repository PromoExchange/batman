class ChangeDefaultValueOnPrebids < ActiveRecord::Migration
  def change
    change_column_default :spree_prebids, :markup, nil
    change_column_default :spree_prebids, :eqp_discount, nil
    Spree::Prebid.where(markup: 0.0).update_all(markup: nil)
    Spree::Prebid.where(eqp_discount: 0.0).update_all(eqp_discount: nil)
  end
end
