require 'rails_helper'

RSpec.describe Spree::Product, type: :model do
  it 'should belong to a supplier' do
    t = Spree::Product.reflect_on_association(:supplier)
    expect(t.macro).to eq :belongs_to
  end

  it 'should have many and belongs to imprint_methods' do
    t = Spree::Product.reflect_on_association(:imprint_methods)
    expect(t.macro).to eq :has_many
  end

  it 'should start with an active state' do
    a = FactoryGirl.build(:product)
    expect(a.state).to eq 'active'
  end

  it 'should go to loading with an loading event' do
    a = FactoryGirl.build(:product)
    a.loading!
    expect(a.state).to eq 'loading'
  end

  it 'should go to active with an loaded event' do
    a = FactoryGirl.build(:product)
    a.loading!
    a.loaded!
    expect(a.state).to eq 'active'
  end

  it 'should go to deleted state with an deleted event' do
    a = FactoryGirl.build(:product)
    a.deleted!
    expect(a.state).to eq 'deleted'
  end

  it 'should give price code of V' do
    p = FactoryGirl.build(:product)
    expect(p.price_code).to eq 'V'
  end
end
