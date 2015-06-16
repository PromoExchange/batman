require 'rails_helper'

RSpec.describe Spree::Upcharge, type: :model do
  it 'should not create supplier upcharge type with nil value' do
    s = FactoryGirl.build(:supplier_upcharge, value: nil)
    expect(s.save).to be_falsey
  end

  it 'should not create product upcharge type with nil value' do
    s = FactoryGirl.build(:product_upcharge, value: nil)
    expect(s.save).to be_falsey
  end

  it 'should create supplier upcharge type with valid values' do
    s = FactoryGirl.build(:supplier_upcharge)
    expect(s.save).to be_truthy
  end

  it 'should create product upcharge type with valid values' do
    s = FactoryGirl.build(:product_upcharge)
    expect(s.save).to be_truthy
  end

  it 'should belong to related' do
    t = Spree::Upcharge.reflect_on_association(:related)
    expect(t.macro).to eq :belongs_to
  end
end
