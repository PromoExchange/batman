class AddEffectiveToPrice < ActiveRecord::Migration
  def change
    add_column :prices, :effective_date, :datetime, null: false,
               :default =>     Time.zone.now
  end
end
