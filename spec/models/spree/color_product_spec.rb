require 'rails_helper'

RSpec.describe Spree::ColorProduct, type: :model do
  it 'should not save with nil product' do
    m = FactoryGirl.build(:color_product, product_id: nil)
    expect(m.save).to be_falsey
  end

  it 'should not save with a nil color' do
    m = FactoryGirl.build(:color_product, color: nil)
    expect(m.save).to be_falsey
  end

  it 'should save with valid values' do
    m = FactoryGirl.build(:color_product)
    expect(m.save).to be_truthy
  end
end
