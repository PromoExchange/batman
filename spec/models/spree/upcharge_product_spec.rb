require 'rails_helper'

RSpec.describe Spree::Upcharge, type: :model do
  xit 'should not create supplier upcharge type with nil value' do
    s = FactoryGirl.build(:supplier_upcharge, value: nil)
    expect(s.save).to be_falsey
  end

  xit 'should not create product upcharge type with nil value' do
    s = FactoryGirl.build(:product_upcharge, value: nil)
    expect(s.save).to be_falsey
  end

  xit 'should create supplier upcharge type with valid values' do
    s = FactoryGirl.build(:supplier_upcharge)
    expect(s.save).to be_truthy
  end

  xit 'should create product upcharge type with valid values' do
    s = FactoryGirl.build(:product_upcharge)
    expect(s.save).to be_truthy
  end
end
