require 'rails_helper'

RSpec.describe Spree::PmsColor, type: :model do
  it 'should not create PmsColor with null name' do
    p = FactoryGirl.build(:pms_color, name: nil)
    expect(p.save).to be_falsey
  end

  it 'should not create PmsColor with null quote' do
    p = FactoryGirl.build(:pms_color, quote: nil)
    expect(p.save).to be_falsey
  end

  it 'should create PmsColor with valid values' do
    p = FactoryGirl.build(:pms_color)
    expect(p.save).to be_truthy
  end

  it 'should create custom PmsColor' do
    p = FactoryGirl.build(:pms_color, :custom)
    expect(p.save).to be_truthy
  end

  it 'should belong_to quote' do
    t = Spree::PmsColor.reflect_on_association(:quote)
    expect(t.macro).to eq :belongs_to
  end
end
