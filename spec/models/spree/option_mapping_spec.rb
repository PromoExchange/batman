require 'rails_helper'

RSpec.describe Spree::OptionMapping, type: :model do
  it 'should not save with a nil dc_acct_num' do
    m = FactoryGirl.build(:option_mapping, dc_acct_num: nil)
    expect(m.save).to be_falsey
  end

  it 'should not save with a nil dc_name' do
    m = FactoryGirl.build(:option_mapping, dc_name: nil)
    expect(m.save).to be_falsey
  end

  it 'should save with a valid option_mapping' do
    m = FactoryGirl.build(:option_mapping)
    expect(m.save).to be_truthy
  end

  it 'should save with a nil px_name' do
    m = FactoryGirl.build(:option_mapping, px_name: nil)
    expect(m.save).to be_truthy
  end

  it 'should save with a nil ignore' do
    m = FactoryGirl.build(:option_mapping, do_not_save: nil)
    expect(m.save).to be_truthy
  end
end
