require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  it 'should belong to an auction' do
    # setup
    t = Spree::Order.reflect_on_association(:bid)

    # exercise
    # verify
    expect(t.macro).to eq :has_one
    # teardown
  end
end
