require 'rails_helper'

RSpec.describe Spree::Quote, type: :model do
  it 'should not save with a nil main_color' do
    quote = FactoryGirl.build(:quote, main_color_id: nil)
    expect(quote.save).to be_falsey
  end

  it 'should not save with a nil shipping_address' do
    quote = FactoryGirl.build(:quote, shipping_address: nil)
    expect(quote.save).to be_falsey
  end

  it 'should not save with a nil imprint_method' do
    quote = FactoryGirl.build(:quote, imprint_method: nil)
    expect(quote.save).to be_falsey
  end

  it 'should not save with a nil quantity' do
    quote = FactoryGirl.build(:quote, quantity: nil)
    expect(quote.save).to be_falsey
  end

  it 'should not save with a less than min quantity' do
    quote = FactoryGirl.build(:quote, quantity: 1)
    expect(quote.save).to be_falsey
  end
end
