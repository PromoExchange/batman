require 'rails_helper'

RSpec.describe Spree::Upcharge, type: :model do
  it 'should not allow invalid value type' do
    u = FactoryGirl.build(:upcharge_invalid_value_type)
    expect(u.save).to be_falsey
  end

  it 'should allow valid values' do
    u = FactoryGirl.build(:upcharge)
    expect(u.save).to be_truthy
  end
end
