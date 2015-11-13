class AddBulletPmsColors < ActiveRecord::Migration
  def change
    Spree::PmsColor.create(
      [
        { name: 'blue300', pantone: '300', hex: '#006eb6' },
        { name: 'red222', pantone: '222', hex: '#82566b' },
        { name: 'gold874', pantone: '874', hex: '#ae8f6f' },
        { name: 'green354', pantone: '354', hex: '#00a95c' },
        { name: 'pink210', pantone: '210', hex: '#ffa2cb' },
        { name: 'violet', pantone: 'Violet', hex: '#7758b3' },
        { name: 'rhodamine', pantone: 'Rhodamine', hex: '#e44c9a' },
        { name: 'rubine', pantone: 'Rubine', hex: '#db487e' },
        { name: 'warmred', pantone: 'Warm Red', hex: '#ff665e' }
      ]
    )
  end
end
