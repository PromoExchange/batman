require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  it 'should belong to an bid' do
    t = Spree::Order.reflect_on_association(:bid)
    expect(t.macro).to eq :has_one
  end
end
