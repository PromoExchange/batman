require 'rails_helper'

RSpec.describe Spree::OptionValuesProduct, type: :model do
  it 'should not allow a nil product_id' do
    ovp = FactoryGirl.build(:option_values_products, product_id: nil)
    expect(ovp.save).to be_falsey
  end

  it 'should not allow a nil option_value_id' do
    ovp = FactoryGirl.build(:option_values_products, option_value_id: nil)
    expect(ovp.save).to be_falsey
  end

  it 'should allow valid values' do
    ovp = FactoryGirl.build(:option_values_products)
    expect(ovp.save).to be_truthy
  end
end
