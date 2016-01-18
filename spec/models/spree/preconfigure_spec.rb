require 'rails_helper'

RSpec.describe Spree::Preconfigure, type: :model do
  it 'should not save with nil product' do
    p = FactoryGirl.build(:preconfigure, product: nil)
    expect(p.save).to be_falsey
  end

  it 'should not save with nil buyer' do
    p = FactoryGirl.build(:preconfigure, buyer: nil)
    expect(p.save).to be_falsey
  end

  it 'should not save with nil imprint method' do
    p = FactoryGirl.build(:preconfigure, imprint_method: nil)
    expect(p.save).to be_falsey
  end

  it 'should not save with nil logo' do
    p = FactoryGirl.build(:preconfigure, logo: nil)
    expect(p.save).to be_falsey
  end

  it 'should not save with nil main color' do
    p = FactoryGirl.build(:preconfigure, main_color: nil)
    expect(p.save).to be_falsey
  end

  it 'should save with valid values' do
    p = FactoryGirl.build(:preconfigure)
    expect(p.save).to be_truthy
  end
end
