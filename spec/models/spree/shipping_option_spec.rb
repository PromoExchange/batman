require 'rails_helper'

RSpec.describe Spree::ShippingOption, type: :model do
  it 'should not save with a nil name' do
    shipping_option = FactoryGirl.build(:shipping_option, :ups_ground, name: nil)
    expect(shipping_option.save).to be_falsey
  end

  it 'should not save with a nil delta' do
    shipping_option = FactoryGirl.build(:shipping_option, :ups_ground, delta: nil)
    expect(shipping_option.save).to be_falsey
  end

  it 'should not save with a nil delivery_date' do
    shipping_option = FactoryGirl.build(:shipping_option, :ups_ground, delivery_date: nil)
    expect(shipping_option.save).to be_falsey
  end

  it 'should not save with a nil delivery_days' do
    shipping_option = FactoryGirl.build(:shipping_option, :ups_ground, delivery_days: nil)
    expect(shipping_option.save).to be_falsey
  end

  it 'should not save with a nil shipping_option' do
    shipping_option = FactoryGirl.build(:shipping_option, :ups_ground, shipping_option: nil)
    expect(shipping_option.save).to be_falsey
  end

  it 'should not save with a nil shipping_cost' do
    shipping_option = FactoryGirl.build(:shipping_option, :ups_ground, shipping_option: nil)
    expect(shipping_option.save).to be_falsey
  end

  it 'should not save with a nil total_cost' do
    shipping_option = FactoryGirl.build(:shipping_option, :ups_ground, total_price: nil)
    expect(shipping_option.save).to be_falsey
  end

  it 'should belong to an auction' do
    t = Spree::ShippingOption.reflect_on_association(:bid)
    expect(t.macro).to eq :belongs_to
  end
end
