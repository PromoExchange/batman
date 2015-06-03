require 'rails_helper'

RSpec.describe Spree::Supplier, type: :model do
  it 'should not create supplier with nulls' do
    s = Spree::Supplier.new
    expect(s.save).to eq false
  end

  it 'should create supplier with values' do
    s = Spree::Supplier.new( name: 'name')
    expect(s.save).to eq true
  end

  it 'should belong to address' do
    t = Spree::Supplier.reflect_on_association(:address)
    expect(t.macro).to eq :belongs_to
  end

  it 'should have many products' do
    t = Spree::Supplier.reflect_on_association(:products)
    expect(t.macro).to eq :has_many
  end

  it 'should have many and belong to option values' do
    t = Spree::Supplier.reflect_on_association(:option_values)
    expect(t.macro).to eq :has_and_belongs_to_many
  end
end
