require 'rails_helper'

RSpec.describe Spree::Price, type: :model do
  it 'should have A discount by 50%' do
    t = Spree::Price::discount_codes[:A]
    expect(t).to eq 0.50
  end

  it 'should have Z discount by 100%' do
    t = Spree::Price::discount_codes[:Z]
    expect(t).to eq 1.00
  end

  it 'should discount price' do
    t = Spree::Price.discount_price('A', 1200)
    expect(t).to eq 600
  end

  it 'should not discount price' do
    t = Spree::Price.discount_price('L', 100)
    expect(t).to eq 100
  end
end
