require 'spec_helper'

RSpec.describe Spree::Auction, type: :model do
  it 'should not save nil values' do
    a = FactoryGirl.build(:auction,
      buyer_id: nil,
      quantity: nil,
      product_id: nil)
    expect(a.save).to be_falsey
  end

  it 'should not save with a nil product' do
    a = FactoryGirl.build(:auction, product_id: nil)
    expect(a.save).to be_falsey
  end

  it 'should generate a reference' do
    a = FactoryGirl.create(:no_ref_auction)
    expect(a.reference).not_to be_empty
  end

  it 'should generate start and end date' do
    a = FactoryGirl.create(:no_date_auction)
    expect(a.started.to_s).not_to be_empty
    expect(a.ended.to_s).not_to be_empty
  end

  it 'should not save with a nil buyer_id' do
    a = FactoryGirl.build(:auction, buyer_id: nil)
    expect(a.save).to be_falsey
  end

  it 'should not save with a nil quantity' do
    a = FactoryGirl.build(:auction, quantity: nil)
    expect(a.save).to be_falsey
  end

  it 'should not save with a nil shipping' do
    a = FactoryGirl.build(:auction, shipping_address: nil)
    expect(a.save).to be_falsey
  end

  it 'should not save with a nil main color' do
    a = FactoryGirl.build(:auction, main_color: nil)
    expect(a.save).to be_falsey
  end

  it 'should not save with a nil status' do
    a = FactoryGirl.build(:auction, status: nil)
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

  it 'should have many adjustments' do
    t = Spree::Auction.reflect_on_association(:adjustments)
    expect(t.macro).to eq :has_many
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
end
