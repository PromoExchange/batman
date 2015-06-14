require 'rails_helper'

RSpec.describe Spree::Favorite, type: :model do
  it 'should not save with a nil buyer_id' do
    m = FactoryGirl.build(:favorite, buyer_id: nil)
    expect(m.save).to be_falsey
  end

  it 'should not save with a nil product_id' do
    m = FactoryGirl.build(:favorite, product_id: nil)
    expect(m.save).to be_falsey
  end

  it 'should save with valid values' do
    m = FactoryGirl.build(:favorite)
    expect(m.save).to be_truthy
  end
end
