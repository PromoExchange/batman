require 'rails_helper'

RSpec.describe Spree::PmsColor, type: :model do
  it 'should not create PmsColor with nulls' do
    # setup
    s = Spree::PmsColor.new
    # exercise
    # verify
    expect(s.save).to eq false
    # teardown
  end

  it 'should not create PmsColor with null pantone' do
    # setup
    s = Spree::PmsColor.new(name: 'name')
    # exercise
    # verify
    expect(s.save).to eq false
    # teardown
  end

  it 'should not create PmsColor with null name' do
    # setup
    s = Spree::PmsColor.new(pantone: 'pantone')
    # exercise
    # verify
    expect(s.save).to eq false
    # teardown
  end

  it 'should create PmsColor with values' do
    # setup
    s = Spree::PmsColor.new(name: 'name', pantone: 'pantone')
    # exercise
    # verify
    expect(s.save).to eq true
    # teardown
  end
end
