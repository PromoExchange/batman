require 'rails_helper'

RSpec.describe Spree::Supplier, type: :model do
  it 'should not create supplier with nulls' do
    s = FactoryGirl.build(:supplier, name: nil)
    expect(s.save).to be_falsey
  end

  it 'should create supplier with values' do
    s = FactoryGirl.build(:supplier)
    expect(s.save).to be_truthy
  end

  it 'should belong to a shipping address' do
    t = Spree::Supplier.reflect_on_association(:ship_address)
    expect(t.macro).to eq :belongs_to
  end

  it 'should belong to a billing address' do
    t = Spree::Supplier.reflect_on_association(:bill_address)
    expect(t.macro).to eq :belongs_to
  end

  it 'should have many products' do
    t = Spree::Supplier.reflect_on_association(:products)
    expect(t.macro).to eq :has_many
  end

  it 'should have many pms_color_supplier' do
    t = Spree::Supplier.reflect_on_association(:pms_colors_supplier)
    expect(t.macro).to eq :has_many
  end
end
