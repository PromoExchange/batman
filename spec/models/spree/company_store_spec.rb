require 'rails_helper'

RSpec.describe Spree::CompanyStore, type: :model do
  it 'should not save with a nil buyer_id' do
    m = FactoryGirl.build(:company_store, buyer_id: nil)
    expect(m.save).to be_falsey
  end

  it 'should not save with a nil supplier_id' do
    m = FactoryGirl.build(:company_store, supplier_id: nil)
    expect(m.save).to be_falsey
  end

  it 'should not save with a nil slug' do
    m = FactoryGirl.build(:company_store, slug: nil)
    expect(m.save).to be_falsey
  end

  it 'should not save with a nil name' do
    m = FactoryGirl.build(:company_store, name: nil)
    expect(m.save).to be_falsey
  end

  it 'should save with valid values' do
    m = FactoryGirl.build(:company_store)
    expect(m.save).to be_truthy
  end

  it 'should allow save with a nil host' do
    m = FactoryGirl.build(:company_store, host: nil)
    expect(m.save).to be_truthy
  end
end