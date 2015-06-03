require 'rails_helper'

RSpec.describe Spree::Message, type: :model do
  it 'should not save with a null owner_id' do
    m = FactoryGirl.build(:message, owner_id: nil)
    expect(m.save).to eq false
  end

  it 'should not save with a null from_id' do
    m = FactoryGirl.build(:message, from_id: nil)
    expect(m.save).to eq false
  end

  it 'should not save with a null to_id' do
    m = FactoryGirl.build(:message, to_id: nil)
    expect(m.save).to eq false
  end

  it 'should not save with a invalid status' do
    m = FactoryGirl.build(:message, status: 'test')
    expect(m.save).to eq false
  end

  it 'should save with valid values' do
    m = FactoryGirl.build(:message)
    expect(m.save).to eq true
  end
end
