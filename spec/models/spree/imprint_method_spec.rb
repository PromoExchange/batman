require 'rails_helper'

RSpec.describe Spree::ImprintMethod, type: :model do
  it 'should not create ImprintMethod with nulls' do
    i = FactoryGirl.build(:imprint_method, name: nil)
    expect(i.save).to be_falsey
  end

  it 'should create ImprintMethod with valid values' do
    i = FactoryGirl.build(:imprint_method)
    expect(i.save).to be_truthy
  end

  it 'should have many products' do
    t = Spree::ImprintMethod.reflect_on_association(:products)
    expect(t.macro).to eq :has_and_belongs_to_many
  end
end
