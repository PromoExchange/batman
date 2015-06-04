require 'rails_helper'

RSpec.describe Spree::Bid, type: :model do
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
