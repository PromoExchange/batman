require 'rails_helper'

RSpec.describe Spree::Supplier, type: :model do
  it 'should not create supplier with nulls' do
    # setup
    s = Spree::Supplier.new
    # exercise
    # verify
    expect(s.save).to eq false
    # teardown
  end

  it 'should create supplier with values' do
    # setup
    s = Spree::Supplier.new( name: 'name')
    # exercise
    # verify
    expect(s.save).to eq true
    # teardown
  end

  it 'should belong to address' do
    # setup
    t = Spree::Supplier.reflect_on_association(:address)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end

  it 'should have many products' do
    # setup
    t = Spree::Supplier.reflect_on_association(:products)

    # exercise
    # verify
    expect(t.macro).to eq :has_many
    # teardown
  end

  it 'should have many and belong to option values' do
    # setup
    t = Spree::Supplier.reflect_on_association(:option_values)

    # exercise
    # verify
    expect(t.macro).to eq :has_and_belongs_to_many
    # teardown
  end
end
