# == Schema Information
#
# Table name: countries
#
#  id           :integer          not null, primary key
#  code_2       :string           not null
#  code_3       :string           not null
#  short_name   :string           not null
#  code_numeric :string           not null
#

require 'rails_helper'

RSpec.describe Country, type: :model do
  it 'should not create Country with nulls' do
    # setup
    p = Country.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create Country with null code_2' do
    # setup
    p = Country.new
    p.code_3 = '123'
    p.code_numeric = 123
    p.short_name = 'short name'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create Country with null code_3' do
    # setup
    p = Country.new
    p.code_2 = '12'
    p.code_numeric = 123
    p.short_name = 'short name'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create Country with null code_numeric' do
    # setup
    p = Country.new
    p.code_2 = '12'
    p.code_3 = '123'
    p.short_name = 'short name'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create Country with code_2 too long' do
    # setup
    p = Country.new
    p.code_2 = '123'
    p.code_3 = '123'
    p.code_numeric = 123
    p.short_name = 'short name'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create Countryd with code_3 too long' do
    # setup
    p = Country.new
    p.code_2 = '12'
    p.code_3 = '1234'
    p.code_numeric = 123
    p.short_name = 'short name'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create Country with code_numeric too long' do
    # setup
    p = Country.new
    p.code_2 = '12'
    p.code_3 = '1234'
    p.code_numeric = 1234
    p.short_name = 'short name'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create Country with code_2 too short' do
    # setup
    p = Country.new
    p.code_2 = '1'
    p.code_3 = '123'
    p.code_numeric = 123
    p.short_name = 'short name'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create Country with code_3 too short' do
    # setup
    p = Country.new
    p.code_2 = '12'
    p.code_3 = '12'
    p.code_numeric = 123
    p.short_name = 'short name'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create Country with code_numeric too short' do
    # setup
    p = Country.new
    p.code_2 = '12'
    p.code_3 = '123'
    p.code_numeric = 12
    p.short_name = 'short name'
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should create Country with valid values' do
    # setup
    p = Country.new
    p.code_2 = '12'
    p.code_3 = '123'
    p.code_numeric = 123
    p.short_name = 'short name'
    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end

  it 'test factory' do
    # setup
    c = build(:category)
    # exercise
    # verify
    expect(c.name).to eq 'CATEGORY'
    # teardown
  end
end
