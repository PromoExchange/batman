class UpdateBrown476HexOnPmsColor < ActiveRecord::Migration
  def change
    pms_color = Spree::PmsColor.where(name: 'brown476')
    pms_color.update_all(hex: '#4f3324') if pms_color.present?
  end
end
