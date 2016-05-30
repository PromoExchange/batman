require 'spec_helper'

RSpec.describe Spree::Auction, type: :model do
  it 'should generate a reference' do
    a = FactoryGirl.create(:no_ref_auction)
    expect(a.reference).not_to be_empty
  end

  it 'should generate start and end date' do
    a = FactoryGirl.create(:no_date_auction)
    expect(a.started.to_s).not_to be_empty
    expect(a.ended.to_s).not_to be_empty
  end

  it 'should not save with a nil quantity' do
    a = FactoryGirl.build(:auction, quantity: nil)
    expect(a.save).to be_falsey
  end

  it 'should save with a nil clone' do
    a = FactoryGirl.build(:auction, clone: nil)
    expect(a.save).to be_truthy
  end

  it 'should save a cloned auction' do
    a = FactoryGirl.build(:cloned_factory, clone: nil)
    expect(a.save).to be_truthy
  end

  it 'should not save with a nil main color' do
    a = FactoryGirl.build(:auction, main_color: nil)
    expect(a.save).to be_falsey
  end

  it 'should not save with a nil state' do
    a = FactoryGirl.build(:auction, state: nil)
    expect(a.save).to be_falsey
  end

  it 'should save with valid values' do
    a = FactoryGirl.build(:auction)
    expect(a.save).to be_truthy
  end

  it 'should have many bids' do
    t = Spree::Auction.reflect_on_association(:bids)
    expect(t.macro).to eq :has_many
  end

  it 'should have one order' do
    t = Spree::Auction.reflect_on_association(:order)
    expect(t.macro).to eq :has_one
  end

  it 'should belong to one imprint method' do
    t = Spree::Auction.reflect_on_association(:imprint_method)
    expect(t.macro).to eq :belongs_to
  end

  it 'should have many pms colors' do
    t = Spree::Auction.reflect_on_association(:pms_colors)
    expect(t.macro).to eq :has_many
  end

  it 'should belong to an address' do
    t = Spree::Auction.reflect_on_association(:shipping_address)
    expect(t.macro).to eq :belongs_to
  end

  it 'should belong to an color product' do
    t = Spree::Auction.reflect_on_association(:main_color)
    expect(t.macro).to eq :belongs_to
  end

  it 'should go ended from end event' do
    a = FactoryGirl.build(:auction)
    a.end
    expect(a.state).to eq 'ended'
  end

  it 'should go to cancel from cancel event (from open)' do
    a = FactoryGirl.build(:auction)
    a.cancel
    expect(a.state).to eq 'cancelled'
  end

  it 'should go to cancel from cancel event (from accepted)' do
    a = FactoryGirl.build(:auction)
    a.accept
    a.cancel
    expect(a.state).to eq 'cancelled'
  end

  it 'should go to waiting_confirmation from accept event' do
    a = FactoryGirl.build(:auction)
    a.accept
    expect(a.state).to eq 'waiting_confirmation'
  end

  it 'should go to unpaid from unpaid event (from open)' do
    a = FactoryGirl.build(:auction)
    a.unpaid
    expect(a.state).to eq 'unpaid'
  end

  it 'should go to unpaid from unpaid event (from waiting_confirmation)' do
    a = FactoryGirl.build(:auction)
    a.accept
    a.unpaid
    expect(a.state).to eq 'unpaid'
  end

  it 'should go to complete from invoice_paid event' do
    a = FactoryGirl.build(:auction)
    a.unpaid
    a.invoice_paid
    expect(a.state).to eq 'complete'
  end

  it 'should go to create_proof from confirm_order event' do
    a = FactoryGirl.build(:auction)
    a.accept
    a.bids << FactoryGirl.build(:bid, state: 'accepted')
    a.confirm_order
    expect(a.state).to eq 'create_proof'
  end

  it 'should go to waiting_proof_approval from upload_proof event' do
    a = FactoryGirl.build(:auction)
    a.accept
    a.bids << FactoryGirl.build(:bid, state: 'accepted')
    a.confirm_order
    a.upload_proof
    expect(a.state).to eq 'waiting_proof_approval'
  end

  it 'should go to in_production from approve_proof event' do
    a = FactoryGirl.build(:auction)
    a.accept
    a.bids << FactoryGirl.build(:bid, state: 'accepted')
    a.confirm_order
    a.upload_proof
    a.approve_proof
    expect(a.state).to eq 'in_production'
  end

  it 'should go to create_proof from reject_proof event' do
    a = FactoryGirl.build(:auction)
    a.accept
    a.bids << FactoryGirl.build(:bid, state: 'accepted')
    a.confirm_order
    a.upload_proof
    a.reject_proof
    expect(a.state).to eq 'create_proof'
  end

  it 'should go to confirm_receipt from enter_tracking event' do
    a = FactoryGirl.build(:auction)
    a.accept
    a.bids << FactoryGirl.build(:bid, state: 'accepted')
    a.confirm_order
    a.upload_proof
    a.approve_proof
    a.enter_tracking
    expect(a.state).to eq 'send_for_delivery'
  end

  it 'should go to waiting_for_rating from confirm_shipment event' do
    a = FactoryGirl.build(:auction)
    a.accept
    a.bids << FactoryGirl.build(:bid, state: 'accepted')
    a.confirm_order
    a.upload_proof
    a.approve_proof
    a.enter_tracking
    a.delivered
    expect(a.state).to eq 'confirm_receipt'
  end

  it 'should go to complete from rate_seller event' do
    a = FactoryGirl.build(:auction)
    a.accept
    a.bids << FactoryGirl.build(:bid, state: 'accepted')
    a.confirm_order
    a.upload_proof
    a.approve_proof
    a.enter_tracking
    a.delivered
    a.delivery_confirmed
    expect(a.state).to eq 'complete'
  end

  it 'should go to in_dispute from reject order event' do
    a = FactoryGirl.build(:auction)
    a.accept
    a.bids << FactoryGirl.build(:bid, state: 'accepted')
    a.confirm_order
    a.upload_proof
    a.approve_proof
    a.enter_tracking
    a.delivered
    a.order_rejected
    expect(a.state).to eq 'in_dispute'
  end

  it 'should go to cancelled from cancel order event' do
    a = FactoryGirl.build(:auction)
    a.accept
    a.bids << FactoryGirl.build(:bid, state: 'accepted')
    a.confirm_order
    a.upload_proof
    a.approve_proof
    a.enter_tracking
    a.delivered
    a.order_rejected
    a.cancel
    expect(a.state).to eq 'cancelled'
  end

  it 'should go to complete from dispute resolved event' do
    a = FactoryGirl.build(:auction)
    a.accept
    a.bids << FactoryGirl.build(:bid, state: 'accepted')
    a.confirm_order
    a.upload_proof
    a.approve_proof
    a.enter_tracking
    a.delivered
    a.order_rejected
    a.dispute_resolved
    expect(a.state).to eq 'complete'
  end

  it 'should not allow invalid shipping agent' do
    a = FactoryGirl.build(:auction, shipping_agent: 'usps')
    expect(a.save).to be_falsey
  end

  it 'should allow a valid shipping agent' do
    a = FactoryGirl.build(:auction, shipping_agent: 'fedex')
    expect(a.save).to be_truthy
  end
end
