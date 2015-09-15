class UpdateHexOnPmsColors < ActiveRecord::Migration
  def change
    pms_color = Spree::PmsColor.where(name: 'blue286')
    pms_color.update_all(hex: '#4169E1') if pms_color.present?
  end
end
