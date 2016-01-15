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

  it 'should discount a zero price' do
    discount = 1.00
    value = 0
    t = Spree::Price.discount_price('K', value)
    expect(((value * discount) - t).abs).to be < 0.0001
  end

  it 'should split price code array' do
    price_code_array = Spree::Price.price_code_to_array('5C')
    expect(price_code_array.size).to be == 5
    expect(%w(C C C C C) & price_code_array).to be_truthy
  end

  it 'should split price code array' do
    price_code_array = Spree::Price.price_code_to_array('CCCCC')
    expect(price_code_array.size).to be == 5
    expect(%w(C C C C C) & price_code_array).to be_truthy
  end

  it 'should split price code array' do
    price_code_array = Spree::Price.price_code_to_array('1A4C')
    expect(price_code_array.size).to be == 5
    expect(%w(A C C C C) & price_code_array).to be_truthy
  end

  it 'should split price code array' do
    price_code_array = Spree::Price.price_code_to_array('3B2C')
    expect(price_code_array.size).to be == 5
    expect(%w(B B B C C) & price_code_array).to be_truthy
  end

  it 'should split price code array lower' do
    price_code_array = Spree::Price.price_code_to_array('3b2c')
    expect(price_code_array.size).to be == 5
    expect(%w(b b b c c) & price_code_array).to be_truthy
  end
end
