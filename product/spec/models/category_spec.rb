require 'rails_helper'

RSpec.describe Category, type: :model do
  it 'should not create category with a nulls' do
    # setup
    p = Category.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create category with a null name' do
    # setup
    p = Category.new
    p.parent_id = 3
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create category with a null parent' do
    # setup
    p = Category.new
    p.name = 'valid name'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should create category with a valid name and parent' do
    # setup
    p = Category.new
    p.name = 'valid name'
    p.parent_id = 10
    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end
end
