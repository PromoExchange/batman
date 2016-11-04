class AddLiveToPrebid < ActiveRecord::Migration
  def change
    add_column :spree_prebids, :live, :boolean, default: false
    if Object.const_defined?('Spree::Prebid')
      Spree::Prebid.all.each do |prebid|
        prebid.live = false
        prebid.save!
      end
    end
  end
end
