class AddNorwoodStandardPms1 < ActiveRecord::Migration
  def change
    Spree::PmsColor.create(
      [
        { name: 'black', pantone: 'black', hex: '#000000' },
        { name: 'Black', pantone: 'black', hex: '#000000' },
        { name: 'Blue', pantone: 'Blue', hex: '#0000ff' },
        { name: 'Brown', pantone: 'Brown', hex: '#a52a2a' },
        { name: 'Burgundy', pantone: 'Burgundy', hex: '#8C001A' },
        { name: 'Copper', pantone: 'Copper', hex: '#8b634b' },
        { name: 'Dark Blue', pantone: 'Dark Blue', hex: '#00239c' },
        { name: 'Dark Gray', pantone: 'Dark Gray', hex: '#a9a9a9' },
        { name: 'Gold', pantone: 'Gold', hex: '#ffc72c' },
        { name: 'Green', pantone: 'Green', hex: '#00ab84' },
        { name: 'Ivory', pantone: 'Ivory', hex: '#FFFFF0' },
        { name: 'Light Gray', pantone: 'Light Gray', hex: '#d3d3d3' },
        { name: 'Light Teal', pantone: 'Light Teal', hex: '#008080' },
        { name: 'Orange', pantone: 'Orange', hex: '#fe5000' },
        { name: 'Pink', pantone: 'Pink', hex: '#d62598' },
        { name: 'Process Blue', pantone: 'Process Blue', hex: '#0085ca' },
        { name: 'Purple', pantone: 'Purple', hex: '#bb29bb' },
        { name: 'Red', pantone: 'Red', hex: '#ef3340' },
        { name: 'Reflex Blue', pantone: 'Reflex Blue', hex: '#001489' },
        { name: 'Silver', pantone: 'Silver', hex: '#8a8d8f' },
        { name: 'Teal', pantone: 'Teal', hex: '#006060' },
        { name: 'white', pantone: 'white', hex: '#FFFFFF' },
        { name: 'White', pantone: 'White', hex: '#FFFFFF' },
        { name: 'Yellow', pantone: 'Yellow', hex: '#fedd00' }
      ]
    )
  end
end
