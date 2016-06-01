require 'rails_helper'

RSpec.describe Spree::ShippingOption, type: :model do
  it 'should not save with a nil name' do
    shipping_option = FactoryGirl.build(:shipping_option, name: nil)
    expect(shipping_option.save).to be_falsey
  end

  it 'should not save with a nil delta' do
    shipping_option = FactoryGirl.build(:shipping_option, delta: nil)
    expect(shipping_option.save).to be_falsey
  end

  it 'should belong to an auction' do
    t = Spree::ShippingOption.reflect_on_association(:bid)
    expect(t.macro).to eq :belongs_to
  end
end
