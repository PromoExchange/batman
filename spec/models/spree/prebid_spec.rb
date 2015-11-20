require 'rails_helper'

RSpec.describe Spree::Prebid, type: :model do
  it 'should not save with a nil seller' do
    p = FactoryGirl.build(:prebid, seller_id: nil)
    expect(p.save).to be_falsey
  end

  it 'should save with valid values' do
    p = FactoryGirl.build(:prebid)
    expect(p.save).to be_truthy
  end

  it 'should have many bids' do
    t = Spree::Prebid.reflect_on_association(:bids)
    expect(t.macro).to eq :has_many
  end

  it 'should have many adjustments' do
    t = Spree::Prebid.reflect_on_association(:adjustments)
    expect(t.macro).to eq :has_many
  end

  it 'should belong to a user' do
    t = Spree::Prebid.reflect_on_association(:seller)
    expect(t.macro).to eq :belongs_to
  end

  it 'should belong to a product' do
    t = Spree::Prebid.reflect_on_association(:supplier)
    expect(t.macro).to eq :belongs_to
  end
end
