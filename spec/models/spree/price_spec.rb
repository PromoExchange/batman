require 'rails_helper'

RSpec.describe Spree::Price, type: :model do
  it 'should have discount [A-K]' do
    discount = 0.50
    ('A'..'K').each do |l|
      t = Spree::Price.discount_codes[l.to_sym]
      expect((discount - t).abs).to be < 0.0001
      discount += 0.05
    end
  end

  it 'should have discount [P-Z]' do
    discount = 0.50
    ('P'..'Z').each do |l|
      t = Spree::Price.discount_codes[l.to_sym]
      expect((discount - t).abs).to be < 0.0001
      discount += 0.05
    end
  end

  it 'should discount price [A-K]' do
    discount = 0.50
    value = 1200
    ('A'..'K').each do |l|
      t = Spree::Price.discount_price(l, value)
      expect(((value * discount) - t).abs).to be < 0.0001
      discount += 0.05
    end
  end

  it 'should discount price [P-Z]' do
    discount = 0.50
    value = 1200
    ('P'..'Z').each do |l|
      t = Spree::Price.discount_price(l, value)
      expect(((value * discount) - t).abs).to be < 0.0001
      discount += 0.05
    end
  end

  it 'should discount price with range' do
    discount = 0.50
    value = 1200
    t = Spree::Price.discount_price('5P', value)
    expect(((value * discount) - t).abs).to be < 0.0001
  end

  it 'should discount price with lower case code' do
    discount = 0.50
    value = 1200
    t = Spree::Price.discount_price('p', value)
    expect(((value * discount) - t).abs).to be < 0.0001
  end

  it 'should (not) discount price with nil' do
    value = 1200
    t = Spree::Price.discount_price(nil, value)
    expect(((value) - t).abs).to be < 0.0001
  end
end
