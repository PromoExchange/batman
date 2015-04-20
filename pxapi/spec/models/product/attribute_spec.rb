require 'rails_helper'

RSpec.describe Product::Attribute, type: :model do
  it 'should not create attribute with null values' do
    # setup
    p = Product::Attribute.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create attribute with null name' do
    # setup
    p = Product::Attribute.new
    p.value = 'value'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create attribute with null value' do
    # setup
    p = Product::Attribute.new
    p.name = 'name'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should create attribute with a valid name' do
    # setup
    p = Product::Attribute.new
    p.name = 'name'
    p.value = 'valid value'
    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end
end
