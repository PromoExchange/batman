require 'rails_helper'

RSpec.describe Spree::Price, type: :model do
  it 'should have A discount by 50%' do
    # setup
    t = Spree::Price::discount_codes[:A]

    # exercise
    # verify
    expect(t).to eq 0.50
    # teardown
  end

  it 'should have Z discount by 100%' do
    # setup
    t = Spree::Price::discount_codes[:Z]

    # exercise
    # verify
    expect(t).to eq 1.00
    # teardown
  end

  it 'should discount price' do
    # setup
    t = Spree::Price.discount_price('A', 1200)

    # exercise
    # verify
    expect(t).to eq 600
    # teardown
  end

  it 'should not discount price' do
    # setup
    t = Spree::Price.discount_price('L', 100)

    # exercise
    # verify
    expect(t).to eq 100
    # teardown
  end
end
