require 'rails_helper'

RSpec.describe Spree::Prebid, type: :model do
  it 'should have many bids' do
    t = Spree::Prebid.reflect_on_association(:bids)
    expect(t.macro).to eq :has_many
  end

  it 'should belong to user' do
    t = Spree::Prebid.reflect_on_association(:user)
    expect(t.macro).to eq :belongs_to
  end

  it 'should belong to a taxon' do
    t = Spree::Prebid.reflect_on_association(:taxon)
    expect(t.macro).to eq :belongs_to
  end
end
