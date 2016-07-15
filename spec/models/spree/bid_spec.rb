require 'rails_helper'

RSpec.describe Spree::Bid, type: :model do
  it 'should not save with a nil auction_id' do
    bid = FactoryGirl.build(:bid)
    bid.auction_id = nil
    expect(bid.save).to be_falsey
  end

  it 'should not save with a nil seller_id' do
    bid = FactoryGirl.build(:bid, seller_id: nil)
    expect(bid.save).to be_falsey
  end

  it 'should save with valid values' do
    bid = FactoryGirl.build(:bid)
    expect(bid.save).to be_truthy
  end

  it 'should not save with an invalid status' do
    bid = FactoryGirl.build(:bid, state: 'invalid')
    expect(bid.save).to be_falsey
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
    bid = FactoryGirl.build(:bid)
    expect(bid.state).to eq 'open'
  end

  it 'should go to accepted after accept event' do
    bid = FactoryGirl.build(:bid)
    bid.non_preferred_accept
    expect(bid.state).to eq 'accepted'
  end

  it 'should go to cancelled after cancell event' do
    bid = FactoryGirl.build(:bid)
    bid.cancel
    expect(bid.state).to eq 'cancelled'
  end

  it 'should not go to cancelled after pay event' do
    bid = FactoryGirl.build(:bid)
    bid.pay
    expect(bid.state).to eq 'open'
  end

  it 'should not go to accepted after cancel event (if cancelled)' do
    bid = FactoryGirl.build(:bid)
    bid.non_preferred_accept
    bid.cancel
    expect(bid.state).to eq 'accepted'
  end

  it 'should create a valid shipping' do
    bid = FactoryGirl.create(:bid)
    expect(bid.service_name).to eq ''
    expect(bid.shipping_cost.to_f).to eq 0.0
    expect(bid.delivery_days).to eq 5
  end

  it 'should create a valid shipping trait' do
    bid = FactoryGirl.build(:bid, :shipping)
    expect(bid.service_name).to eq 'Basic Shipping'
    expect(bid.shipping_cost.to_f).to eq 10.00
    expect(bid.delivery_days).to eq 6
  end

  it 'should go to completed after pay event' do
    bid = FactoryGirl.build(:bid)
    bid.non_preferred_accept
    bid.pay
    expect(bid.state).to eq 'completed'
  end

  it 'has delivery date > 3 days time' do
    bid = FactoryGirl.build(:bid)
    expect(bid.delivery_date).to be > Time.zone.now + 3.days
  end

  it 'should have_many shipping options' do
    t = Spree::Bid.reflect_on_association(:shipping_options)
    expect(t.macro).to eq :has_many
  end

  # Skipping pending reorganize 
  xit 'should delete shipping_options' do
    bid_with_shipping = FactoryGirl.create(:bid, :with_shipping_options)
    expect { bid_with_shipping.destroy }.to change { Spree::ShippingOption.count }.by(-5)
  end
end
