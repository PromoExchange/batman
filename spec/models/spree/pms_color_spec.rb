require 'rails_helper'

RSpec.describe Spree::PmsColor, type: :model do
  it 'should not create PmsColor with null pantone' do
    p = FactoryGirl.build(:pms_color, pantone: nil)
    expect(p.save).to be_falsey
  end

  it 'should not create PmsColor with null name' do
    p = FactoryGirl.build(:pms_color, name: nil)
    expect(p.save).to be_falsey
  end

  it 'should create PmsColor with valid values' do
    p = FactoryGirl.build(:pms_color)
    expect(p.save).to be_truthy
  end

  it 'should have and belong to suppliers' do
    t = Spree::PmsColor.reflect_on_association(:suppliers)
    expect(t.macro).to eq :has_and_belongs_to_many
  end
end
