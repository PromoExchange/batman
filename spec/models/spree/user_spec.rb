require 'rails_helper'

RSpec.describe Spree::User, type: :model do
  it 'should have many tax rates' do
    t = Spree::User.reflect_on_association(:tax_rates)
    expect(t.macro).to eq :has_many
  end

  it 'should cancel bids' do
    b = FactoryGirl.create(:bid)
    u = b.seller
    count = Spree::Bid.where(seller: b.seller, state: 'open').count
    expect(count).to eq 1
    u.cancel_bids
    count = Spree::Bid.where(seller: b.seller, state: 'open').count
    expect(count).to eq 0
  end
end
