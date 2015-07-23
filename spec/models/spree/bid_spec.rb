require 'rails_helper'

RSpec.describe Spree::Bid, type: :model do
  it 'should not save with a nil auction_id' do
    b = FactoryGirl.build(:bid)
    b.auction_id = nil
    expect(b.save).to be_falsey
  end

  it 'should not save with a nil seller_id' do
    b = FactoryGirl.build(:bid, seller_id: nil)
    expect(b.save).to be_falsey
  end

  it 'should save with valid values' do
    b = FactoryGirl.build(:bid)
    expect(b.save).to be_truthy
  end

  it 'should not save with an invalid status' do
    b = FactoryGirl.build(:bid, status: 'invalid')
    expect(b.save).to be_falsey
  end

  xit 'should cascade delete order'

  it 'should belong to an auction' do
    t = Spree::Bid.reflect_on_association(:auction)
    expect(t.macro).to eq :belongs_to
  end

  it 'should belong to an order' do
    t = Spree::Bid.reflect_on_association(:order)
    expect(t.macro).to eq :belongs_to
  end

  it 'should belong to prebid' do
    t = Spree::Bid.reflect_on_association(:prebid)
    expect(t.macro).to eq :belongs_to
  end
end
