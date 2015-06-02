require 'rails_helper'

RSpec.describe Spree::Prebid, type: :model do
  it 'should have many bids' do
    # setup
    t = Spree::Prebid.reflect_on_association(:bids)

    # exercise
    # verify
    expect(t.macro).to eq :has_many
    # teardown
  end

  it 'should belong to user' do
    # setup
    t = Spree::Prebid.reflect_on_association(:user)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end

  it 'should belong to a taxon' do
    # setup
    t = Spree::Prebid.reflect_on_association(:taxon)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end
end
