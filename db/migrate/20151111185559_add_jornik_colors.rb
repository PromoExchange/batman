class AddJornikColors < ActiveRecord::Migration
  def change
    Spree::PmsColor.create(
      [
        { name: 'green349', pantone: '349', hex: '#477258' },
        { name: 'yellow102', pantone: '102', hex: '#ffec2d' },
        { name: 'brown471', pantone: '471', hex: '#be7b54' }
      ]
    )
  end
end
