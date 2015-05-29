require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  it 'should belong to an auction' do
    # setup
    t = Spree::Order.reflect_on_association(:auction)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end
end
