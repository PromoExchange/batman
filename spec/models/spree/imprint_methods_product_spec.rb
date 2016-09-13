require 'rails_helper'

RSpec.describe Spree::ImprintMethodsProduct, type: :model do
  it 'should not save with a nil product' do
    imp = FactoryGirl.build(:imprint_method_product, product_id: nil)
    expect(imp.save).to be_falsey
  end

  it 'should not save with a nil imprint method' do
    imp = FactoryGirl.build(:imprint_method_product, imprint_method_id: nil)
    expect(imp.save).to be_falsey
  end

  it 'should save with valid values' do
    imp = FactoryGirl.build(:imprint_method_product)
    expect(imp.save).to be_truthy
  end

  it 'should belong to a product' do
    t = Spree::ImprintMethodsProduct.reflect_on_association(:product)
    expect(t.macro).to eq :belongs_to
  end

  it 'should belong to an imprint method' do
    t = Spree::ImprintMethodsProduct.reflect_on_association(:imprint_method)
    expect(t.macro).to eq :belongs_to
  end
end
