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
    b = FactoryGirl.build(:bid, state: 'invalid')
    expect(b.save).to be_falsey
  end

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

  it 'should state with an open state' do
    b = FactoryGirl.build(:bid)
    expect(b.state).to eq 'open'
  end

  it 'should go to accepted after accept event' do
    b = FactoryGirl.build(:bid)
    b.accept
    expect(b.state).to eq 'accepted'
  end

  it 'should go to cancelled after cancell event' do
    b = FactoryGirl.build(:bid)
    b.cancel
    expect(b.state).to eq 'cancelled'
  end

  it 'should not go to cancelled after pay event' do
    b = FactoryGirl.build(:bid)
    b.pay
    expect(b.state).to eq 'open'
  end

  it 'should not go to accepted after cancel event (if cancelled)' do
    b = FactoryGirl.build(:bid)
    b.accept
    b.cancel
    expect(b.state).to eq 'accepted'
  end

  it 'should go to completed after pay event' do
    b = FactoryGirl.build(:bid)
    b.accept
    b.pay
    expect(b.state).to eq 'completed'
  end
end
