require 'rails_helper'

RSpec.describe Auction::Category, type: :model do
  it 'should not create attribute with null values' do
    # setup
    p = Product::Attribute.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end
end
