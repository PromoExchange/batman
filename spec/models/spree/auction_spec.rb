require 'spec_helper'

RSpec.describe Spree::Auction, type: :model do
  it 'should not save nil values' do
    a = FactoryGirl.build(:auction,
      buyer_id: nil,
      quantity: nil,
      product_id: nil)
    expect(a.save).to be_falsey
  end

  it 'should not save with a null product' do
    a = FactoryGirl.build(:auction,
      product_id: nil)
    expect(a.save).to be_falsey
  end

  it 'should not save with a null buyer_id' do
    a = FactoryGirl.build(:auction,
      buyer_id: nil)
    expect(a.save).to be_falsey
  end

  it 'should not save with a null quantity' do
    a = FactoryGirl.build(:auction,
      quantity: nil)
    expect(a.save).to be_falsey
  end

  it 'should save with valid values' do
    a = FactoryGirl.build(:auction)
    expect(a.save).to be_truthy
  end

  it "should have many bids" do
    t = Spree::Auction.reflect_on_association(:bids)
    expect(t.macro).to eq :has_many
  end

  it "should have one order" do
    t = Spree::Auction.reflect_on_association(:order)
    expect(t.macro).to eq :has_one
  end

  it "should have many adjustments" do
    t = Spree::Auction.reflect_on_association(:adjustments)
    expect(t.macro).to eq :has_many
  end
end
