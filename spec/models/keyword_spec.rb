# == Schema Information
#
# Table name: keywords
#
#  id         :integer          not null, primary key
#  word       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Keyword, type: :model do

  it 'should not create Keyword with a null word' do
    # setup
    k = Keyword.new
    # exercise
    # verify
    expect(k.save).to eq false
    # teardown
  end

  it 'should create Keyword with a valid word' do
    # setup
    k = Keyword.new
    k.word = "WORD"
    # exercise
    # verify
    expect(k.save).to eq true
    # teardown
  end

  it 'test factory' do
    # setup
    k = build(:keyword)
    # exercise
    # verify
    expect(k.word).to eq 'WORD'
    # teardown
  end
end
