require 'rails_helper'

RSpec.describe 'Product load logic' do
  it 'should clean a product color' do
    expect(ProductLoad.clean_color_name('304 - Yellow')).to eq 'Yellow'
  end

  it 'should clean a product color' do
    expect(ProductLoad.clean_color_name('Yellow')).to eq 'Yellow'
  end

  it 'should clean a product color' do
    expect(ProductLoad.clean_color_name(' - Yellow')).to eq 'Yellow'
  end

  it 'should clean a product color' do
    expect(ProductLoad.clean_color_name('Yellow -')).to eq 'Yellow -'
  end
end
