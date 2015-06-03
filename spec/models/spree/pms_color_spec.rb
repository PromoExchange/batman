require 'rails_helper'

RSpec.describe Spree::PmsColor, type: :model do
  it 'should not create PmsColor with nulls' do
    s = Spree::PmsColor.new
    expect(s.save).to eq false
  end

  it 'should not create PmsColor with null pantone' do
    s = Spree::PmsColor.new(name: 'name')
    expect(s.save).to eq false
  end

  it 'should not create PmsColor with null name' do
    s = Spree::PmsColor.new(pantone: 'pantone')
    expect(s.save).to eq false
  end

  it 'should create PmsColor with values' do
    s = Spree::PmsColor.new(name: 'name', pantone: 'pantone')
    expect(s.save).to eq true
  end
end
