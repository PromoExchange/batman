require 'rails_helper'

RSpec.describe Category, type: :model do
  it 'should not create category with a null name' do
    # setup
    p = Category.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should create category with a valid name' do
    # setup
    p = Category.new
    p.name = 'valid name'
    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end
end
