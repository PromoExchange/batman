require 'rails_helper'

RSpec.describe Product::Detail, type: :model do
  it 'should not create product detail with null values' do
    # setup
    p = Product::Detail.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create product detail with a null name' do
    # setup
    p = Product::Detail.new
    p.price = 11.00
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create product detail with a null price' do
    # setup
    p = Product::Detail.new
    p.name = 'name'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should create product detail with a null name' do
    # setup
    p = Product::Detail.new
    p.name = 'name'
    p.price = 11.00
    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end
end
