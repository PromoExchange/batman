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
#

require 'rails_helper'

require "money-rails/test_helpers"
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

  it 'test factory' do
    # setup
    c = build(:price)
    # exercise
    # verify
    # expect(c.value).to eq 1.5
    is_expected.to monetize(:value_cents)
    expect(c.pricetype).to eq 'base'
    # teardown
  end
end
