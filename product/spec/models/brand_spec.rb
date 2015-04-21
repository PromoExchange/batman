require 'rails_helper'

RSpec.describe Brand, type: :model do

  it 'should not create Brand with nulls' do
    # setup
    p = Brand.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should create Brand with valid values' do
    # setup
    p = Brand.new
    p.brand = "BRAND"
    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end

end
