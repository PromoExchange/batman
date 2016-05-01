require 'rails_helper'

RSpec.describe Spree::AuctionPayment, type: :model do
  it 'should not save with a nil bid_id' do
    ap = FactoryGirl.build(:auction_payment, bid_id: nil)
    expect(ap.save).to be_falsey
  end

  it 'should save with valid values' do
    ap = FactoryGirl.build(:auction_payment, status: 'test')
    expect(ap.save).to be_truthy
  end

  it 'should have one bid' do
    t = Spree::AuctionPayment.reflect_on_association(:bid)
    expect(t.macro).to eq :belongs_to
  end

  it 'should have one product request' do
    t = Spree::AuctionPayment.reflect_on_association(:request_idea)
    expect(t.macro).to eq :belongs_to
  end
end
