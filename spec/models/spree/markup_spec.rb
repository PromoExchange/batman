require 'rails_helper'

RSpec.describe Spree::Markup, type: :model do
  it 'should not save markup with a nil supplier' do
    imp = FactoryGirl.build(:markup, supplier_id: nil)
    expect(imp.save).to be_falsey
  end

  it 'should not save markup with a nil markup' do
    imp = FactoryGirl.build(:markup, markup: nil)
    expect(imp.save).to be_falsey
  end

  it 'should not save markup with a nil company_store' do
    imp = FactoryGirl.build(:markup, company_store_id: nil)
    expect(imp.save).to be_falsey
  end

  it 'should will save valid markup' do
    imp = FactoryGirl.build(:markup)
    expect(imp.save).to be_truthy
  end
end
