require 'rails_helper'

RSpec.describe Spree::UpchargeType, type: :model do
  it 'should not create upcharge type with nil name' do
    s = FactoryGirl.build(:upcharge_type, name: nil)
    expect(s.save).to be_falsey
  end

  it 'should create upcharge type with valid values' do
    s = FactoryGirl.build(:upcharge_type)
    expect(s.save).to be_truthy
  end
end
