require 'rails_helper'

RSpec.describe Spree::Bid, type: :model do
  it 'should belong to an auction' do
    # setup
    t = Spree::Bid.reflect_on_association(:auction)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end

  it 'should belong to an order' do
    # setup
    t = Spree::Bid.reflect_on_association(:order)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end

  it 'should belong to prebid' do
    # setup
    t = Spree::Bid.reflect_on_association(:prebid)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end
end
