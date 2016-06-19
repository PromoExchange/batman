require 'rails_helper'

RSpec.describe Spree::Markup, type: :model do
  it 'should not save markup with a nil supplier' do
    markup = FactoryGirl.build(:markup, supplier_id: nil)
    expect(markup.save).to be_falsey
  end

  it 'should not save markup with a nil markup' do
    markup = FactoryGirl.build(:markup, markup: nil)
    expect(markup.save).to be_falsey
  end

  it 'should not save markup with a nil company_store' do
    markup = FactoryGirl.build(:markup, company_store_id: nil)
    expect(markup.save).to be_falsey
  end

  it 'should will save valid markup' do
    markup = FactoryGirl.build(:markup)
    expect(markup.save).to be_truthy
  end

  it 'should return true for eqp?' do
    markup = FactoryGirl.build(:markup)
    expect(markup.eqp?).to be_falsey
  end

  it 'should return true for eqp?' do
    markup = FactoryGirl.build(:markup, :eqp_discount)
    expect(markup.eqp?).to be_truthy
  end
end
