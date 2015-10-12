class UpdateBrown476ToBrown < ActiveRecord::Migration
  def change
    pms_color = Spree::PmsColor.where(name: 'brown476')
    pms_color.update_all(hex: '#6e5e52') if pms_color.present?
  end
end
