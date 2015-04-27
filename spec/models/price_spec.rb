# == Schema Information
#
# Table name: prices
#
#  id             :integer          not null, primary key
#  value_cents    :integer          default(0), not null
#  value_currency :string           default("USD"), not null
#  pricetype      :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  lower          :string
#  upper          :string
#  effective_date :datetime         default(Mon, 27 Apr 2015 14:50:16 UTC +00:00), not null
#  code           :string
#

require 'rails_helper'

require 'money-rails/test_helpers'
include MoneyRails::TestHelpers

RSpec.describe Price, type: :model do
  it 'should not save Price with nulls' do
    # setup
    p = Price.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not save Price with null pricetype' do
    # setup
    p = Price.new(value: 1.00)
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should should not save Price with an invalid pricetype' do
    # setup
    p = Price.new(pricetype: 'frog')
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should should save Price with null value' do
    # setup
    p = Price.new(pricetype: 'base', code: 'X')
    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end

  it 'should should not save Price with invalid code' do
    # setup
    p = Price.new(pricetype: 'base', code: 'M')
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'test factory' do
    # setup
    c = build(:price)
    # exercise
    # verify
    # expect(c.value).to eq 1.5
    is_expected.to monetize(:value_cents)
    expect(c.pricetype).to eq 'base'
    expect(c.effective_date).to eq '1/1/2015'
    expect(c.code).to eq 'A'
    # teardown
  end
end
