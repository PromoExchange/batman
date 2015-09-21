class AddPmsColorsSpector < ActiveRecord::Migration
  def change
    Spree::PmsColor.create(
      [
        { name: 'blue301', pantone: '301', hex: '#004b87' },
        { name: 'blue294', pantone: '294', hex: '#002f6c' },
        { name: 'blue2695', pantone: '2695', hex: '#2e1a47' },
        { name: 'green7480', pantone: '7480', hex: '#00bf6f' },
        { name: 'green3295', pantone: '3295', hex: '#007864' },
        { name: 'green3425', pantone: '3425', hex: '#006341' },
        { name: 'teal321', pantone: '321', hex: '#008c95' },
        { name: 'red187', pantone: '187', hex: '#a6192e' },
        { name: 'red216', pantone: '216', hex: '#7d2248' },
        { name: 'purple259', pantone: '259', hex: '#9b26b6' },
        { name: 'purple2415', pantone: '2415', hex: '#9e007e' },
        { name: 'brown469', pantone: '469', hex: '#693f23' },
        { name: 'orange166', pantone: '166', hex: '#e35205' },
        { name: 'yellow380', pantone: '380', hex: '#dbe442' },
        { name: 'yellow110', pantone: '110', hex: '#daaa00' }
      ]
    )
  end
end
